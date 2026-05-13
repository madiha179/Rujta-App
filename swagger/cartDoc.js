/**
 * @swagger
 * tags:
 *   name: Cart 
 *   description: managing user cart
 */

/**
 * @swagger
 * /api/v1/cart:
 *   post:
 *     summary: Add drug to cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - drug_id
 *               - branch_id
 *               - quantity
 *             properties:
 *               drug_id:
 *                 type: integer
 *                 example: 1
 *               branch_id:
 *                 type: integer
 *                 example: 2
 *               quantity:
 *                 type: integer
 *                 example: 3
 *     responses:
 *       200:
 *         description: Drug added successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: drug added successfully
 *       400:
 *         description: Missing required fields
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: drug_id, branch_id, quantity required
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Database error
 */

/**
 * @swagger
 * /api/v1/cart:
 *   get:
 *     summary: Get all cart items
 *     tags: [Cart ]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User cart retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 cart:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       cart_id:
 *                         type: integer
 *                         example: 1
 *                       drug_name:
 *                         type: string
 *                         example: Antinal
 *                       quantity:
 *                         type: integer
 *                         example: 2
 *                       price:
 *                         type: string
 *                         example: "25.00"
 *                       total_price:
 *                         type: string
 *                         example: "50.00"
 *                 total_price:
 *                   type: string
 *                   example: "150.00"
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Cart is empty
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: cart is empty
 *       500:
 *         description: Database error
 */

/**
 * @swagger
 * /api/v1/cart/{id}:
 *   delete:
 *     summary: Remove item from cart
 *     tags: [Cart ]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Drug removed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: drug successfully deleted
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Item not found
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Item not found
 *       500:
 *         description: Database error
 */

/**
 * @swagger
 * /api/v1/cart:
 *   delete:
 *     summary: Clear all cart items
 *     tags: [Cart ]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Cart cleared successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: cart cleared successfully
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Database error
 */