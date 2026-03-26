/**
 * @swagger
 * /api/v1/users/signup:
 *   post:
 *     summary: Register a new customer
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email, password, confirmPassword, phone]
 *             properties:
 *               name:
 *                 type: string
 *                 example: John Doe
 *               email:
 *                 type: string
 *                 example: john@example.com
 *               password:
 *                 type: string
 *                 example: Pass@1234
 *               confirmPassword:
 *                 type: string
 *                 example: Pass@1234
 *               phone:
 *                 type: string
 *                 example: 01012345678
 *     responses:
 *       201:
 *         description: Registration successful. OTP sent to your email.
 *       400:
 *         description: Validation error
 */
/**
 * @swagger
 * /api/v1/users/verifyemail:
 *   post:
 *     summary: Verify email with OTP after signup
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [otp]
 *             properties:
 *               otp:
 *                 type: string
 *                 example: "1234"
 *     responses:
 *       200:
 *         description: Email verified. Returns JWT token.
 *       400:
 *         description: Invalid or expired OTP
 */
/**
 * @swagger
 * /api/v1/users/login:
 *   post:
 *     summary: Login for customers and admins
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:
 *                 type: string
 *                 example: john@example.com
 *               password:
 *                 type: string
 *                 example: Pass@1234
 *     responses:
 *       200:
 *         description: Login successful. Returns JWT token.
 *       401:
 *         description: Invalid email or password
 *       403:
 *         description: Please verify your email first
 */
/**
 * @swagger
 * /api/v1/users/forgot-password:
 *   post:
 *     summary: Send OTP to email for password reset
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email]
 *             properties:
 *               email:
 *                 type: string
 *                 example: john@example.com
 *     responses:
 *       200:
 *         description: OTP sent to your email
 *       404:
 *         description: No account found with this email
 */
/**
 * @swagger
 * /api/v1/users/verify-reset-otp:
 *   post:
 *     summary: Verify OTP for password reset
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [otp]
 *             properties:
 *               otp:
 *                 type: string
 *                 example: "5678"
 *     responses:
 *       200:
 *         description: OTP verified. Returns reset token.
 *       400:
 *         description: Invalid or expired OTP
 */
/**
 * @swagger
 * /api/v1/users/reset-password/{token}:
 *   post:
 *     summary: Reset password using token from verify-reset-otp
 *     tags: [Auth]
 *     parameters:
 *       - in: path
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Reset token received from verify-reset-otp
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [newPassword, confirmPassword]
 *             properties:
 *               newPassword:
 *                 type: string
 *                 example: NewPass@1234
 *               confirmPassword:
 *                 type: string
 *                 example: NewPass@1234
 *     responses:
 *       200:
 *         description: Password reset successful. Returns JWT token.
 *       400:
 *         description: Validation error
 *       401:
 *         description: Invalid or expired session
 */