# ScoutX

Sports talent discovery platform (Flutter, web + Windows + Android). Firebase + Cloudinary + Gemini AI.

## Deployment workflow (IMPORTANT)

After bug fixes or successful changes are made:

1. Wait for the user to verify and confirm the changes are done — ask them each time.
2. Only if they say yes, build and deploy:
   ```
   flutter build web
   firebase deploy --only hosting --project scoutx-ed075
   ```
3. Live URL: https://scoutx-ed075.web.app

Never deploy without explicit confirmation from the user for that batch of changes.
