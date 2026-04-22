/**
 * @swagger
 * tags:
 *   name: User Home Screen APIs
 *   description: APIs for browsing drugs by user location
 */

/**
 * @swagger
 * /api/v1/user/drugsbylocation/{lng}/{lat}:
 *   get:
 *     summary: Get all drugs near a location
 *     tags: [User Home Screen APIs]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *         example: 31.2357
 *       - in: path
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *         example: 30.0444
 *     responses:
 *       200:
 *         description: List of drugs near the location
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 results:
 *                   type: integer
 *                   example: 3
 *                 data:
 *                   type: object
 *                   properties:
 *                     data:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           drug_name:
 *                             type: string
 *                             example: Paracetamol 500mg
 *                           image_url:
 *                             type: string
 *                             example: http://localhost:3000/images/Antinal.jpeg
 *                           price:
 *                             type: string
 *                             example: "25.00"
 *                           pharmacy_name:
 *                             type: string
 *                             example: El Ezaby
 *                           branch_address:
 *                             type: string
 *                             example: 47 Abbas El-Akkad, Nasr City
 *                           distance:
 *                             type: number
 *                             example: 1.2
 *       400:
 *         description: Missing location parameters
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: User location(lat,lng) is required
 *       401:
 *         description: Unauthorized - Login required
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: error
 *                 message:
 *                   type: string
 *                   example: Unauthorized. Please log in.
 *       500:
 *         description: Internal Server Error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Internal server error.
 */

/**
 * @swagger
 * /api/v1/user/drugsbylocation/{lng}/{lat}/{key}:
 *   get:
 *     summary: Search drugs by name near a location
 *     tags: [User Home Screen APIs]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *         example: 31.2357
 *       - in: path
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *         example: 30.0444
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         example: paracetamol
 *     responses:
 *       200:
 *         description: Matching drugs near the location
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 result:
 *                   type: integer
 *                   example: 2
 *                 data:
 *                   type: object
 *                   properties:
 *                     data:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           drug_name:
 *                             type: string
 *                             example: Paracetamol 500mg
 *                           image_url:
 *                             type: string
 *                             example: http://localhost:3000/images/Antinal.jpeg
 *                           price:
 *                             type: string
 *                             example: "25.00"
 *                           pharmacy_name:
 *                             type: string
 *                             example: El Ezaby
 *                           branch_address:
 *                             type: string
 *                             example: 47 Abbas El-Akkad, Nasr City
 *                           distance:
 *                             type: number
 *                             example: 1.2
 *       400:
 *         description: Missing location parameters
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: User location(lat,lng) is required
 *       401:
 *         description: Unauthorized - Login required
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: error
 *                 message:
 *                   type: string
 *                   example: Unauthorized. Please log in.
 *       500:
 *         description: Internal Server Error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Internal server error.
 */