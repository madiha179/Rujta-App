/**
 * @swagger
 * tags:
 *   name: Admin Home Screen APIS
 *   description: APIs for managing drugs and branches from admin dashboard
 */

/**
 * @swagger
 * /api/v1/admin/alldrugs:
 *   get:
 *     summary: Get all drugs from all branches
 *     tags: [Admin Home Screen APIS]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: A list of all drugs
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
 *                   example: 1
 *                 data:
 *                   type: object
 *                   properties:
 *                     drugs:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           pharmacy_name:
 *                             type: string
 *                             example: El Ezaby
 *                           branchId:
 *                             type: integer
 *                             example: 1
 *                           branch_address:
 *                             type: string
 *                             example: 47 Abbas El-Akkad, Nasr City
 *                           drug_name:
 *                             type: string
 *                             example: Zyrtec 10mg
 *                           drugId:
 *                             type: integer
 *                             example: 5
 *                           price:
 *                             type: string
 *                             example: "60.00"
 *                           exp_date:
 *                             type: string
 *                             format: date-time
 *                             example: 2026-09-04T21:00:00.000Z
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
 *       403:
 *         description: Forbidden - Admins only
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
 *                   example: Access denied. Admins only.
 *       500:
 *         description: Internal Server Error
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
 *                   example: Internal server error.
 */
/**
 * @swagger
 * /api/v1/admin/drugs:
 *   post:
 *     summary: Add a new drug to a branch
 *     tags: [Admin Home Screen APIS]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - expDate
 *               - price
 *               - branchId
 *               - quantity
 *             properties:
 *               name:
 *                 type: string
 *                 example: Zyrtec 10mg
 *               expDate:
 *                 type: string
 *                 format: date-time
 *                 example: 2026-09-04T21:00:00.000Z
 *               price:
 *                 type: number
 *                 example: 60.00
 *               branchId:
 *                 type: integer
 *                 example: 1
 *               quantity:
 *                 type: integer
 *                 example: 100
 *     responses:
 *       201:
 *         description: Drug added successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: Drug added successfully
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
 *       403:
 *         description: Forbidden - Admins only
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
 *                   example: Access denied. Admins only.
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
 * /api/v1/admin/drugs/{branchId}/{drugId}:
 *   patch:
 *     summary: Update drug price and quantity in a branch
 *     tags: [Admin Home Screen APIS]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: branchId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *       - in: path
 *         name: drugId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 5
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               newPrice:
 *                 type: number
 *                 example: 75.00
 *               quantity:
 *                 type: integer
 *                 example: 50
 *     responses:
 *       200:
 *         description: Drug updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Drug updated successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     affectedRows:
 *                       type: integer
 *                       example: 1
 *       400:
 *         description: Missing branchId or drugId
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Please provide branch id and drug id
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
 *       403:
 *         description: Forbidden - Admins only
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
 *                   example: Access denied. Admins only.
 *       404:
 *         description: Drug not found in this branch
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: fail
 *                 message:
 *                   type: string
 *                   example: Update failed. Drug not found in this branch
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
 * /api/v1/admin/drugs/{branchId}/{drugId}:
 *   delete:
 *     summary: Delete a drug from a branch
 *     tags: [Admin Home Screen APIS]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: branchId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *       - in: path
 *         name: drugId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 5
 *     responses:
 *       204:
 *         description: Drug deleted successfully (no content)
 *       400:
 *         description: Missing branchId or drugId
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Please provide branch id and drug id
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
 *       403:
 *         description: Forbidden - Admins only
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
 *                   example: Access denied. Admins only.
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
 * /api/v1/admin/drugs/{key}:
 *   get:
 *     summary: Search for a drug by name or keyword
 *     tags: [Admin Home Screen APIS]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         example: Zyrtec
 *     responses:
 *       200:
 *         description: Search results returned successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       pharmacy_name:
 *                         type: string
 *                         example: El Ezaby
 *                       branchId:
 *                         type: integer
 *                         example: 1
 *                       branch_address:
 *                         type: string
 *                         example: 47 Abbas El-Akkad, Nasr City
 *                       drug_name:
 *                         type: string
 *                         example: Zyrtec 10mg
 *                       drugId:
 *                         type: integer
 *                         example: 5
 *                       price:
 *                         type: string
 *                         example: "60.00"
 *                       exp_date:
 *                         type: string
 *                         format: date-time
 *                         example: 2026-09-04T21:00:00.000Z
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
 *       403:
 *         description: Forbidden - Admins only
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
 *                   example: Access denied. Admins only.
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