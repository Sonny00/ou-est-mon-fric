// backend/src/scripts/generate-tags.ts

import { DataSource } from 'typeorm';
import { User } from '../users/entities/user.entity';
import * as dotenv from 'dotenv';

// ⭐ Charger les variables d'environnement
dotenv.config();

async function generateTags() {
  const host = process.env.DATABASE_HOST || 'postgres';
  const port = parseInt(process.env.DATABASE_PORT || '5432');
  const username = process.env.DATABASE_USER || 'postgres';
  const password = process.env.DATABASE_PASSWORD || 'postgres';
  const database = process.env.DATABASE_NAME || 'ouestmonfric_dev';

  const dataSource = new DataSource({
    type: 'postgres',
    host,
    port,
    username,
    password,
    database,
    entities: [User],
    synchronize: false,
  });

  console.log('📡 Connexion à la base de données...');
  console.log(`   Host: ${host}`);
  console.log(`   Database: ${database}`);
  console.log(`   User: ${username}`);
  
  try {
    await dataSource.initialize();
    console.log('✅ Connecté !');
    
    const userRepo = dataSource.getRepository(User);

    const users = await userRepo.find();
    console.log(`📊 ${users.length} utilisateurs trouvés`);

    for (const user of users) {
      if (!user.tag) {
        const baseName = user.name.replace(/[^a-zA-Z0-9]/g, '').substring(0, 20);
        const randomNumber = Math.floor(1000 + Math.random() * 9000);
        user.tag = `${baseName}#${randomNumber}`;
        await userRepo.save(user);
        console.log(`✅ Tag généré pour ${user.name}: ${user.tag}`);
      } else {
        console.log(`⏭️  ${user.name} a déjà un tag: ${user.tag}`);
      }
    }

    await dataSource.destroy();
    console.log('✅ Terminé !');
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur:', error);
    process.exit(1);
  }
}

generateTags();