import swaggerJSDoc from 'swagger-jsdoc';
import swaggerUI from 'swagger-ui-express';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Rujta App API Documentation',
      version: '1.0.0',
      description: 'API documentation for Rujta project',
    },
  },
  apis: [path.join(__dirname, 'authDoc.js')],
};

const swaggerSpec = swaggerJSDoc(options);

const swaggerDoc = (app) => {
  app.use('/api-docs', swaggerUI.serve, swaggerUI.setup(swaggerSpec));
  console.log('Swagger Docs available at /api-docs ✅');
};

export default swaggerDoc;