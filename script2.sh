#!/bin/bash

echo "🚀 Création de l'architecture Backend NestJS pour OuEstMonFric..."

# Créer le dossier backend s'il n'existe pas
mkdir -p backend
cd backend

# Initialiser le projet NestJS
echo "📦 Installation de NestJS..."
npx @nestjs/cli new . --package-manager npm --skip-git

# Créer l'architecture des dossiers
echo "📁 Création de l'arborescence..."

# Auth module
mkdir -p src/auth/dto
mkdir -p src/auth/guards

# Users module
mkdir -p src/users/entities
mkdir -p src/users/dto

# Friends module
mkdir -p src/friends/entities
mkdir -p src/friends/dto

# Tabs module
mkdir -p src/tabs/entities
mkdir -p src/tabs/dto

# Notifications module
mkdir -p src/notifications/entities
mkdir -p src/notifications/dto

# Common utilities
mkdir -p src/common/decorators
mkdir -p src/common/filters
mkdir -p src/common/interceptors
mkdir -p src/common/pipes

echo "✅ Structure créée !"

# Installer les dépendances nécessaires
echo "📦 Installation des dépendances..."
npm install --save @nestjs/typeorm typeorm pg
npm install --save @nestjs/passport passport passport-jwt
npm install --save @nestjs/jwt
npm install --save @nestjs/config
npm install --save bcrypt
npm install --save class-validator class-transformer
npm install --save @nestjs/websockets @nestjs/platform-socket.io
npm install --save-dev @types/passport-jwt @types/bcrypt

echo "✅ Dépendances installées !"

# Créer les fichiers de base

# .env.example
cat > .env.example << 'EOF'
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=ouestmonfric

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION=7d

# App
PORT=3000
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:8080
EOF

# .env
cp .env.example .env

# docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: ouestmonfric-db
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: ouestmonfric
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    container_name: ouestmonfric-redis
    restart: always
    ports:
      - "6379:6379"

  api:
    build: .
    container_name: ouestmonfric-api
    restart: always
    ports:
      - "3000:3000"
    environment:
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_USER: postgres
      DATABASE_PASSWORD: postgres
      DATABASE_NAME: ouestmonfric
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRATION: ${JWT_EXPIRATION}
    depends_on:
      - postgres
      - redis
    volumes:
      - .:/app
      - /app/node_modules

volumes:
  postgres_data:
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
EOF

# .dockerignore
cat > .dockerignore << 'EOF'
node_modules
dist
.env
.git
.gitignore
README.md
EOF

# User Entity
cat > src/users/entities/user.entity.ts << 'EOF'
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Exclude } from 'class-transformer';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  phoneNumber: string;

  @Column({ nullable: true })
  name: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column()
  @Exclude()
  password: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

# Tab Entity
cat > src/tabs/entities/tab.entity.ts << 'EOF'
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinC