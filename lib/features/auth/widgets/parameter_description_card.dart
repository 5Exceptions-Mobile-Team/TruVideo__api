import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

class ParameterDescriptionCard extends StatelessWidget {
  const ParameterDescriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Pallet.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'POST /api/login',
            style: GoogleFonts.firaCode(
              fontSize: 14,
              color: Colors.green[400],
            ),
          ),
          const SizedBox(height: 24),
          
          // Parameters Section
          Text(
            'Parameters',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Pallet.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildParameter(
            name: 'x-authentication-api-key',
            type: 'string',
            required: true,
            description: 'Your unique ID card that proves you\'re allowed to use this service. Think of it like your username - it identifies who you are.',
            example: 'Provided by TruVideo team',
            icon: Icons.vpn_key_rounded,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          
          _buildParameter(
            name: 'x-multitenant-external-id',
            type: 'string',
            required: true,
            description: 'Your account number that identifies which account you\'re using. This helps the system know which workspace or organization you belong to.',
            example: 'Configured by your Partner',
            icon: Icons.business_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          
          _buildParameter(
            name: 'x-authentication-signature',
            type: 'string',
            required: true,
            description: 'A digital fingerprint that proves the request came from you and hasn\'t been tampered with. It\'s automatically created using your Secret Key and the timestamp.',
            example: 'Auto-generated (HMAC SHA256)',
            icon: Icons.fingerprint_rounded,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          
          _buildParameter(
            name: 'timestamp',
            type: 'string (ISO 8601)',
            required: true,
            description: 'The exact date and time this request was made. This ensures the request is recent (must be within 30 minutes) for security purposes. It\'s automatically generated when you click "Try it".',
            example: '2024-09-06T05:36:25.966Z',
            icon: Icons.access_time_rounded,
            color: Colors.teal,
          ),
          const SizedBox(height: 24),
          
          // How It Works Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'How Authentication Works',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStep(
                  step: 1,
                  title: 'Enter Your Credentials',
                  description: 'Provide your API Key, Secret Key, and External ID. These are like your login credentials.',
                ),
                const SizedBox(height: 8),
                _buildStep(
                  step: 2,
                  title: 'Generate Secure Timestamp',
                  description: 'The system automatically creates a timestamp showing the exact time of your request. This ensures your request is fresh and secure.',
                ),
                const SizedBox(height: 8),
                _buildStep(
                  step: 3,
                  title: 'Create Digital Signature',
                  description: 'Using your Secret Key and the timestamp, a unique signature is generated. This is like a digital fingerprint that proves the request came from you.',
                ),
                const SizedBox(height: 8),
                _buildStep(
                  step: 4,
                  title: 'Send Request',
                  description: 'Your request is sent to the server with all the required information. The server verifies your signature to ensure it\'s really you.',
                ),
                const SizedBox(height: 8),
                _buildStep(
                  step: 5,
                  title: 'Receive Access Token',
                  description: 'If everything is correct, you\'ll receive an access token. This token is like a temporary pass that lets you make other API requests. Use it in the "Authorization: Bearer <token>" header for future requests.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Security Best Practices
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      size: 20,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Security Best Practices',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSecurityTip('Never share your Secret Key with anyone'),
                _buildSecurityTip('Keep your API credentials secure and private'),
                _buildSecurityTip('Tokens expire after 24 hours - you\'ll need to generate a new one'),
                _buildSecurityTip('Always use HTTPS when making API requests'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Status Codes Section
          Text(
            'Response Status Codes',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Pallet.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusCode(
            code: '200',
            title: 'OK - Success',
            description: 'Authentication successful! You received your access token and can now use it for API requests.',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatusCode(
            code: '401',
            title: 'Unauthorized',
            description: 'Your API key or signature is incorrect. Double-check your credentials and make sure your Secret Key matches.',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatusCode(
            code: '403',
            title: 'Forbidden',
            description: 'Your account doesn\'t have permission to access this. Contact your administrator if you believe this is an error.',
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildStatusCode(
            code: '400',
            title: 'Bad Request',
            description: 'Something is wrong with your request - maybe a field is missing, the format is incorrect, or the timestamp is too old (must be within 30 minutes).',
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildStatusCode(
            code: '500',
            title: 'Server Error',
            description: 'Something went wrong on the server side. Try again later or contact support if the problem persists.',
            color: Colors.red,
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.firaCode(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: required
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  required ? 'Required' : 'Optional',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: required ? Colors.red[700] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Pallet.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Pallet.glassBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Example: ',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Pallet.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    example,
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: Pallet.primaryColor,
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
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
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
              const SizedBox(height: 2),
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
            color: Colors.green[700],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
    // Return a darker shade of the color
    if (color == Colors.green) return Colors.green[700]!;
    if (color == Colors.orange) return Colors.orange[700]!;
    if (color == Colors.red) return Colors.red[700]!;
    if (color == Colors.amber) return Colors.amber[700]!;
    return color;
  }
}
