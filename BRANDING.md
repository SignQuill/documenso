# Branding Configuration

This application supports custom branding through environment variables. You can rebrand the application by setting the following environment variables:

## Environment Variables

### `NEXT_PUBLIC_APP_NAME`
- **Description**: The full name of your application
- **Default**: `Documenso`
- **Example**: `MyDocumentSigningApp`

### `NEXT_PUBLIC_APP_SHORT_NAME`
- **Description**: The short name of your application (used in web manifests)
- **Default**: `Documenso`
- **Example**: `MyApp`

## Usage

### Setting Environment Variables

1. Create a `.env` file in the root directory
2. Add your branding variables:

```bash
# Branding Configuration
NEXT_PUBLIC_APP_NAME=YourAppName
NEXT_PUBLIC_APP_SHORT_NAME=YourApp
```

### Processing Branding Files

The application includes a script to process branding files and replace template variables with your custom values:

```bash
npm run branding:process
```

This script will:
- Process `apps/remix/public/site.webmanifest`
- Process `packages/assets/site.webmanifest`
- Replace `{{APP_NAME}}` and `{{APP_SHORT_NAME}}` template variables with your environment variable values

### Build Process

The branding processing is automatically included in the build process. When you run:

```bash
npm run build
```

The build will:
1. Extract and compile translations
2. Process branding files
3. Build the application

## Files Updated

The following files have been updated to support dynamic branding:

- `packages/lib/constants/app.ts` - Added `APP_NAME()` and `APP_SHORT_NAME()` functions
- `apps/remix/app/components/embed/embed-document-completed.tsx` - Uses `APP_NAME()` instead of hardcoded "Documenso"
- `packages/email/template-components/template-document-image.tsx` - Uses `APP_NAME()` for alt text
- `apps/remix/public/site.webmanifest` - Uses template variables `{{APP_NAME}}` and `{{APP_SHORT_NAME}}`
- `packages/assets/site.webmanifest` - Uses template variables `{{APP_NAME}}` and `{{APP_SHORT_NAME}}`

## Development

During development, you can run the branding processing manually:

```bash
npm run branding:process
```

This will update the webmanifest files with your current environment variable values.

### Docker Development

When using Docker for development, the branding processing is automatically included:

1. **Docker Compose Development:**
   ```bash
   docker compose -f docker-compose.dev.yml up
   ```
   
   The docker-compose.dev.yml file includes branding environment variables:
   ```yaml
   environment:
     - NEXT_PUBLIC_APP_NAME=SignQuill
     - NEXT_PUBLIC_APP_SHORT_NAME=SignQuill
   ```

2. **Docker Build Process:**
   The Dockerfile.dev includes branding processing in the build:
   ```dockerfile
   # Process branding files
   RUN npm run branding:process
   ```

3. **Docker Startup Script:**
   The scripts/docker-startup.sh script processes branding before starting the development server.

## Notes

- The branding variables are prefixed with `NEXT_PUBLIC_` to ensure they are available in the client-side code
- If the environment variables are not set, the application will fall back to "Documenso"
- The branding processing script is idempotent and can be run multiple times safely 