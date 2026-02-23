import app from './app';
import dotenv from 'dotenv';

dotenv.config();

const port = Number(process.env.PORT) || 3000;

app.listen(port, '0.0.0.0', () => {
    console.log(`Server running at http://localhost:${port}`);
    console.log(`Swagger docs available at http://localhost:${port}/docs`);
});