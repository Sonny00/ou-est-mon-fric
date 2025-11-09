// backend/src/auth/auth.service.ts

import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
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

  async register(registerDto: RegisterDto) {
    console.log('📝 Register attempt:', registerDto.email); // Debug

    // Vérifier si l'email existe déjà
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    // Hash du password
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    // Créer l'utilisateur
    const user = this.userRepository.create({
      ...registerDto,
      password: hashedPassword,
    });

    const savedUser = await this.userRepository.save(user);
    console.log('✅ User created:', savedUser.id); // Debug

    // Générer le token JWT
    const token = this.generateToken(savedUser);

    return {
      user: {
        id: savedUser.id,
        email: savedUser.email,
        name: savedUser.name,
        phoneNumber: savedUser.phoneNumber,
        avatarUrl: savedUser.avatarUrl,
      },
      token,
    };
  }

  async login(loginDto: LoginDto) {
    console.log('🔐 Login attempt:', loginDto.email); // Debug

    // Trouver l'utilisateur
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
    });

    console.log('👤 User found:', user ? user.id : 'NOT FOUND'); // Debug

    if (!user) {
      console.log('❌ User not found'); // Debug
      throw new UnauthorizedException('Invalid credentials');
    }

    // Vérifier le password
    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    console.log('🔑 Password valid:', isPasswordValid); // Debug

    if (!isPasswordValid) {
      console.log('❌ Invalid password'); // Debug
      throw new UnauthorizedException('Invalid credentials');
    }

    // Générer le token JWT
    const token = this.generateToken(user);
    console.log('✅ Login successful, token generated'); // Debug

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phoneNumber: user.phoneNumber,
        avatarUrl: user.avatarUrl,
      },
      token,
    };
  }

  async googleLogin(googleUser: any) {
    console.log('🔵 Google login attempt:', googleUser.email); // Debug

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
      const newUser = this.userRepository.create({
        email: googleUser.email,
        name: googleUser.name,
        googleId: googleUser.googleId,
        avatarUrl: googleUser.avatarUrl,
        isEmailVerified: true,
        password: '', // Pas de mot de passe pour Google OAuth
      });
      user = await this.userRepository.save(newUser);
    } else if (!user.googleId) {
      // Lier le compte Google existant
      user.googleId = googleUser.googleId;
      user.isEmailVerified = true;
      user = await this.userRepository.save(user);
    }

    // Générer le token JWT
    const token = this.generateToken(user);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
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

    console.log('🎫 Generating token with payload:', payload); // Debug
    const token = this.jwtService.sign(payload);
    console.log('🎫 Token generated:', token.substring(0, 20) + '...'); // Debug
    
    return token;
  }

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
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      isEmailVerified: user.isEmailVerified,
    };
  }
}