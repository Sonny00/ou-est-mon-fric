// backend/src/users/dto/user-stats.dto.ts

export class UserStatsDto {
  activeTabs: number;
  totalFriends: number;
  totalOwed: number;    // Montant qu'on me doit
  totalDue: number;     // Montant que je dois
  balance: number;      // Balance totale
}
