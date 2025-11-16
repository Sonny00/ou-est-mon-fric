// backend/src/friends/dto/send-friend-request.dto.ts

import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class SendFriendRequestDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^.+#\d{4}$/, {
    message: 'Tag must be in format: Username#1234',
  })
  tag: string; // ⭐ Changé de "email" à "tag"
}