/**
 * @swagger
 * tags:
 *   name: Admin Home
 *   description: Admin dashboard APIs for drugs management
 */

/**
 * @swagger
 * /api/v1/admin/alldrugs:
 *   get:
 *     summary: Get all drugs (paginated)
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: List of drugs
 *         content:
 *           application/json:
 *             example:
 *               status: success
 *               currentPage: 1
 *               totalPages: 3
 *               totalItems: 25
 *               results: 2
 *               data:
 *                 drugs:
 *                   - pharmacy_name: El Ezaby
 *                     branchId: 1
 *                     branch_address: Nasr City
 *                     drug_name: Zyrtec 10mg
 *                     drugId: 5
 *                     image_url: "photo.jpeg"
 *                     price: "60.00"
 *                     exp_date: 2026-09-04T21:00:00.000Z
 */

/**
 * @swagger
 * /api/v1/admin/drugs:
 *   post:
 *     summary: Add new drug
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     description: |
 *       Example request:
 *       name: LAMIFEN 250 MG
 *       branchId: 1
 *       price: 112
 *       quantity: 70
 *       expDate: 2026-08-01
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: LAMIFEN 250 MG
 *               image_name:
 *                 type: string
 *                 format: binary
 *               branchId:
 *                 type: integer
 *                 example: 1
 *               price:
 *                 type: number
 *                 example: 112
 *               quantity:
 *                 type: integer
 *                 example: 70
 *               expDate:
 *                 type: string
 *                 format: date
 *                 example: 2026-08-01
 *     responses:
 *       201:
 *         description: Drug added successfully
 */

/**
 * @swagger
 * /api/v1/admin/drugs/{branchId}/{drugId}:
 *   patch:
 *     summary: Update drug price & quantity
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: branchId
 *         required: true
 *         schema:
 *           type: integer
 *       - in: path
 *         name: drugId
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               newPrice:
 *                 type: number
 *                 example: 120
 *               quantity:
 *                 type: integer
 *                 example: 50
 *     responses:
 *       200:
 *         description: Updated successfully
 *         content:
 *           application/json:
 *             example:
 *               message: Drug updated successfully
 *               data:
 *                 affectedRows: 1
 */

/**
 * @swagger
 * /api/v1/admin/drugs/{branchId}/{drugId}:
 *   delete:
 *     summary: Delete drug from branch
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: branchId
 *         required: true
 *         schema:
 *           type: integer
 *       - in: path
 *         name: drugId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Deleted successfully
 */

/**
 * @swagger
 * /api/v1/admin/drugs/search/{key}:
 *   get:
 *     summary: Search drug by name
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *           example: zyrtec
 *     responses:
 *       200:
 *         description: Search results
 *         content:
 *           application/json:
 *             example:
 *               data:
 *                 - pharmacy_name: El Ezaby
 *                   branchId: 1
 *                   branch_address: Nasr City
 *                   drug_name: Zyrtec 10mg
 *                   drugId: 5
 *                   price: "60.00"
 */

/**
 * @swagger
 * /api/v1/admin/drugs/total:
 *   get:
 *     summary: Get total stock of all drugs
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Total stock returned
 *         content:
 *           application/json:
 *             example:
 *               data:
 *                 Total_Stock: 1500
 */

/**
 * @swagger
 * /api/v1/admin/drugs/low:
 *   get:
 *     summary: Get low stock count
 *     tags: [Admin Home]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Low stock count returned
 *         content:
 *           application/json:
 *             example:
 *               data:
 *                 Low_Stock: 12
 */