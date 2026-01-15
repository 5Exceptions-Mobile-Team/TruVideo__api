import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class ParameterDescriptionCard extends StatelessWidget {
  const ParameterDescriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Pallet.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.api_rounded,
                color: Pallet.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Request',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Pallet.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Pallet.glassBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Pallet.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'POST',
                  style: GoogleFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Pallet.successColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/api/login',
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  color: Pallet.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // API Description Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Pallet.primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Pallet.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'About Login API',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'This is the first and most important step before you can use any feature of the TruVideo API. Think of it like checking in at a secure building - you need to prove who you are before you can enter.'
                'When you call this API, you provide your credentials (API Key and Secret Key) to prove your identity. If everything checks out, the system gives you a special access token - think of it as a temporary ID badge or pass.\n\n'
                'This token is your proof of identity for all future actions. Every time you want to upload a file, check status, or do anything else, you\'ll include this token with your request. It tells the system "I\'ve already proven who I am, so you can trust this request." '
                'For security, tokens expire after 24 hours. This means even if someone else gets your token, they can only use it for a limited time. When it expires, simply call this API again to get a fresh token.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Pallet.textPrimary,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Parameters Section
        Row(
          children: [
            Icon(Icons.tune_rounded, size: 20, color: Pallet.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Parameters',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Pallet.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildParameter(
          name: 'x-authentication-api-key',
          type: 'string',
          required: true,
          description:
              'Think of this as your login username. It\'s a special code that identifies you to the system. Just like you need a username to log into your email, you need this API Key to prove you\'re allowed to use the service. You get this from the TruVideo team when you sign up.',
          example: 'Provided by TruVideo team',
          icon: Icons.vpn_key_rounded,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),

        _buildParameter(
          name: 'x-multitenant-external-id',
          type: 'string',
          required: true,
          description:
              'This is like your account number. If you\'re part of a company or organization, this number tells the system which specific account or workspace you belong to. It\'s like having multiple bank accounts - each has its own account number. Your partner or administrator will give you this number.',
          example: 'Configured by your Partner',
          icon: Icons.business_rounded,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),

        _buildParameter(
          name: 'x-authentication-signature',
          type: 'string',
          required: true,
          description:
              'This is like a digital signature that proves the message is really from you. Just like signing your name on a document, this digital signature confirms your identity. The good news? You don\'t need to create it yourself - just fill in your credentials and click "Try it", and the system handles everything automatically.',
          example: 'Auto-generated for you',
          icon: Icons.fingerprint_rounded,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),

        _buildParameter(
          name: 'timestamp',
          type: 'string (ISO 8601)',
          required: true,
          description:
              'This is the exact date and time when you\'re making this request, written in a special format. Think of it like a timestamp on a photo - it shows when the photo was taken. The system uses this to make sure your request is fresh and recent (not older than 30 minutes) for security. Don\'t worry - it\'s created automatically when you click "Try it", so you don\'t need to do anything.',
          example: '2024-09-06T05:36:25.966Z',
          icon: Icons.access_time_rounded,
          color: Colors.teal,
        ),
        const SizedBox(height: 32),

        // How It Works Section
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: Pallet.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'How It Works',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Pallet.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Pallet.primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Pallet.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Pallet.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How Authentication Works',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStep(
                step: 1,
                title: 'Enter Your Credentials',
                description:
                    'Fill in the three fields: your API Key (like your username), Secret Key (like your password), and External ID (your account number). These are the keys to unlock the service.',
              ),
              const SizedBox(height: 20),
              _buildStep(
                step: 2,
                title: 'System Creates Timestamp',
                description:
                    'When you click "Try it", the system automatically writes down the exact time you made the request. It\'s like putting a date stamp on a letter - it shows when it was sent. This helps keep things secure by making sure requests are recent.',
              ),
              const SizedBox(height: 20),
              _buildStep(
                step: 3,
                title: 'System Creates Your Digital Signature',
                description:
                    'The system takes your Secret Key and the timestamp, then mixes them together using a special formula to create a unique signature. Think of it like a wax seal on an old letter - it proves the message is really from you and hasn\'t been changed.',
              ),
              const SizedBox(height: 20),
              _buildStep(
                step: 4,
                title: 'Request is Sent',
                description:
                    'Your request, along with all your information and the signature, is sent to the server. The server checks everything to make sure it\'s really you making the request.',
              ),
              const SizedBox(height: 20),
              _buildStep(
                step: 5,
                title: 'You Get Your Access Token',
                description:
                    'If everything checks out, the server sends you back a special token (like a temporary ID card). This token lets you make other requests to the system. Think of it like a day pass at a theme park - you use it to get into different attractions (API features). Keep it safe and use it in future requests!',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Security Best Practices
        Row(
          children: [
            Icon(Icons.security_rounded, size: 22, color: Pallet.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Security Tips',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Pallet.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Pallet.primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Pallet.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      size: 18,
                      color: Pallet.warningColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Security Best Practices',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSecurityTip('Never share your Secret Key with anyone'),
              _buildSecurityTip('Keep your API credentials secure and private'),
              _buildSecurityTip(
                'Tokens expire after 24 hours - you\'ll need to generate a new one',
              ),
              _buildSecurityTip('Always use HTTPS when making API requests'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Status Codes Section
        Row(
          children: [
            Icon(Icons.http_rounded, size: 22, color: Pallet.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Response Status Codes',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Pallet.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildStatusCode(
          code: '200',
          title: 'OK - Success',
          description:
              'Authentication successful! You received your access token and can now use it for API requests.',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatusCode(
          code: '401',
          title: 'Unauthorized',
          description:
              'Your API key or signature is incorrect. Double-check your credentials and make sure your Secret Key matches.',
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildStatusCode(
          code: '403',
          title: 'Forbidden',
          description:
              'Your account doesn\'t have permission to access this. Contact your administrator if you believe this is an error.',
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildStatusCode(
          code: '400',
          title: 'Bad Request',
          description:
              'Something is wrong with your request - maybe a field is missing, the format is incorrect, or the timestamp is too old (must be within 30 minutes).',
          color: Colors.amber,
        ),
        const SizedBox(height: 16),
        _buildStatusCode(
          code: '500',
          title: 'Server Error',
          description:
              'Something went wrong on the server side. Try again later or contact support if the problem persists.',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildParameter({
    required String name,
    required String type,
    required bool required,
    required String description,
    required String example,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Pallet.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.firaCode(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Pallet.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: required
                                ? Pallet.errorColor.withOpacity(0.1)
                                : Pallet.greyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            required ? 'Required' : 'Optional',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: required
                                  ? Pallet.errorColor
                                  : Pallet.greyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type,
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        color: Pallet.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Pallet.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Pallet.cardBackgroundSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Pallet.glassBorder, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example: ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Pallet.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    example,
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Pallet.glassBorder, width: 1),
          ),
          child: Center(
            child: Text(
              '$step',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Pallet.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Pallet.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Pallet.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: Pallet.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Pallet.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCode({
    required String code,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pallet.cardBackgroundAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Text(
              code,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _getDarkerColor(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Pallet.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDarkerColor(Color color) {
    // Return a darker version of the color
    return Color.fromRGBO(
      (color.red * 0.7).round().clamp(0, 255),
      (color.green * 0.7).round().clamp(0, 255),
      (color.blue * 0.7).round().clamp(0, 255),
      1.0,
    );
  }
}
