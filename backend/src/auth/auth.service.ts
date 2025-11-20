// backend/src/auth/auth.service.ts

import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from '../users/entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  // ⭐ Générer un tag unique
  private async generateUniqueTag(name: string): Promise<string> {
    const baseName = name.replace(/[^a-zA-Z0-9]/g, '').substring(0, 20);
    let tag: string;
    let exists = true;

    while (exists) {
      const randomNumber = Math.floor(1000 + Math.random() * 9000);
      tag = `${baseName}#${randomNumber}`;
      const existingUser = await this.userRepository.findOne({ where: { tag } });
      exists = !!existingUser;
    }

    return tag;
  }

  async register(registerDto: RegisterDto) {
    console.log('📝 Register attempt:', registerDto.email);

    // Vérifier si l'email existe déjà
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    // Hash du password
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    // ⭐ Générer le tag unique
    const tag = await this.generateUniqueTag(registerDto.name);

    // Créer l'utilisateur
    const user = this.userRepository.create({
      ...registerDto,
      password: hashedPassword,
      tag, // ⭐ AJOUTER
    });

    const savedUser = await this.userRepository.save(user);
    console.log('✅ User created:', savedUser.id, 'with tag:', savedUser.tag);

    // Générer le token JWT
    const token = this.generateToken(savedUser);

    return {
      user: {
        id: savedUser.id,
        email: savedUser.email,
        name: savedUser.name,
        tag: savedUser.tag, // ⭐ AJOUTER
        phoneNumber: savedUser.phoneNumber,
        avatarUrl: savedUser.avatarUrl,
      },
      token,
    };
  }

  async login(loginDto: LoginDto) {
    console.log('🔐 Login attempt:', loginDto.email);

    // Trouver l'utilisateur
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
    });

    console.log('👤 User found:', user ? user.id : 'NOT FOUND');

    if (!user) {
      console.log('❌ User not found');
      throw new UnauthorizedException('Invalid credentials');
    }

    // Vérifier le password
    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    console.log('🔑 Password valid:', isPasswordValid);

    if (!isPasswordValid) {
      console.log('❌ Invalid password');
      throw new UnauthorizedException('Invalid credentials');
    }

    // Générer le token JWT
    const token = this.generateToken(user);
    console.log('✅ Login successful, token generated');

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        tag: user.tag, // ⭐ AJOUTER
        phoneNumber: user.phoneNumber,
        avatarUrl: user.avatarUrl,
      },
      token,
    };
  }

  async googleLogin(googleUser: any) {
    console.log('🔵 Google login attempt:', googleUser.email);

    // Chercher l'utilisateur par Google ID
    let user = await this.userRepository.findOne({
      where: { googleId: googleUser.googleId },
    });

    // Si pas trouvé, chercher par email
    if (!user) {
      user = await this.userRepository.findOne({
        where: { email: googleUser.email },
      });
    }

    // Si toujours pas trouvé, créer un nouvel utilisateur
    if (!user) {
      // ⭐ Générer le tag pour les nouveaux utilisateurs Google
      const tag = await this.generateUniqueTag(googleUser.name);
      
      const newUser = this.userRepository.create({
        email: googleUser.email,
        name: googleUser.name,
        googleId: googleUser.googleId,
        avatarUrl: googleUser.avatarUrl,
        isEmailVerified: true,
        password: '', // Pas de mot de passe pour Google OAuth
        tag, // ⭐ AJOUTER
      });
      user = await this.userRepository.save(newUser);
    } else if (!user.googleId) {
      // Lier le compte Google existant
      user.googleId = googleUser.googleId;
      user.isEmailVerified = true;
      
      // ⭐ Générer un tag si l'utilisateur n'en a pas
      if (!user.tag) {
        user.tag = await this.generateUniqueTag(user.name);
      }
      
      user = await this.userRepository.save(user);
    }

    // Générer le token JWT
    const token = this.generateToken(user);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        tag: user.tag, // ⭐ AJOUTER
        avatarUrl: user.avatarUrl,
      },
      token,
    };
  }

  private generateToken(user: User): string {
    const payload = {
      sub: user.id,
      email: user.email,
      name: user.name,
    };

    console.log('🎫 Generating token with payload:', payload);
    const token = this.jwtService.sign(payload);
    console.log('🎫 Token generated:', token.substring(0, 20) + '...');
    
    return token;
  }

  // ⭐ CORRIGER : Ajouter le tag
  async getMe(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      tag: user.tag, // ⭐ AJOUTER
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      isEmailVerified: user.isEmailVerified,
    };
  }
}