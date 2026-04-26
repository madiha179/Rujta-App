/**
 * @swagger
 * tags:
 *   name: User Profile
 *   description: User profile management APIs
 */

/**
 * @swagger
 * /api/v1/user/userprofile:
 *   get:
 *     summary: Get current user data
 *     tags: [User Profile]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User data retrieved
 *         content:
 *           application/json:
 *             example:
 *               data:
 *                 result:
 *                   id: 1
 *                   name: Madiha
 *                   email: madiha@gmail.com
 *                   phone: "01012345678"
 */

/**
 * @swagger
 * /api/v1/user/userprofile/updates/name:
 *   patch:
 *     summary: Update user name
 *     tags: [User Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             name: Madiha Ahmed
 *     responses:
 *       200:
 *         description: Name updated successfully
 *         content:
 *           application/json:
 *             example:
 *               data:
 *                 result:
 *                   affectedRows: 1
 */

/**
 * @swagger
 * /api/v1/user/userprofile/updates/phone:
 *   patch:
 *     summary: Update user phone
 *     tags: [User Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             phone: "01098765432"
 *     responses:
 *       200:
 *         description: Phone updated successfully
 *         content:
 *           application/json:
 *             example:
 *               data:
 *                 result:
 *                   affectedRows: 1
 */

/**
 * @swagger
 * /api/v1/user/userprofile/updates/password:
 *   patch:
 *     summary: Update user password
 *     tags: [User Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             currentPassword: "123456"
 *             newPassword: "new123456"
 *             confirmNewPassword: "new123456"
 *     responses:
 *       200:
 *         description: Password updated successfully
 *         content:
 *           application/json:
 *             example:
 *               message: password updated successfully
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             example:
 *               message: new password and confirm password are not match
 *       404:
 *         description: User not found
 */
/**
 * @swagger
 * /api/v1/user/userprofile/admin:
 *   get:
 *     summary: Get current admin ID
 *     tags: [User Profile]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Admin ID retrieved successfully
 *         content:
 *           application/json:
 *             example:
 *               adminId: 1
 *       403:
 *         description: Forbidden - Admins only
 *         content:
 *           application/json:
 *             example:
 *               message: Access denied. Admins only.
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             example:
 *               message: Unauthorized. Please log in.
 *       500:
 *         description: Internal server error
 */