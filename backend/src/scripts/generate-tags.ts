// backend/src/scripts/generate-tags.ts

import { DataSource } from 'typeorm';
import { User } from '../users/entities/user.entity';

async function generateTags() {
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'ouestmonfric',
    entities: [User],
  });

  await dataSource.initialize();
  const userRepo = dataSource.getRepository(User);

  const users = await userRepo.find({ where: { tag: null } });
  console.log(`��� ${users.length} utilisateurs sans tag`);

  for (const user of users) {
    const baseName = user.name.replace(/[^a-zA-Z0-9]/g, '').substring(0, 20);
    const randomNumber = Math.floor(1000 + Math.random() * 9000);
    user.tag = `${baseName}#${randomNumber}`;
    await userRepo.save(user);
    console.log(`✅ Tag généré pour ${user.name}: ${user.tag}`);
  }

  await dataSource.destroy();
  console.log('✅ Terminé !');
}

generateTags().catch(console.error);
