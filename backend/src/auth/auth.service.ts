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

    await this.userRepository.save(user);

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

  async login(loginDto: LoginDto) {
    // Trouver l'utilisateur
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Vérifier le password
    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
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

  async googleLogin(googleUser: any) {
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
      user = this.userRepository.create({
        ...googleUser,
        isEmailVerified: true,
      });
      await this.userRepository.save(user);
    } else if (!user.googleId) {
      // Lier le compte Google existant
      user.googleId = googleUser.googleId;
      user.isEmailVerified = true;
      await this.userRepository.save(user);
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
    
    return this.jwtService.sign(payload);
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