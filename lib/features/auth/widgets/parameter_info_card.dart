import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

class ParameterInfoCard extends StatefulWidget {
  const ParameterInfoCard({super.key});

  @override
  State<ParameterInfoCard> createState() => _ParameterInfoCardState();
}

class _ParameterInfoCardState extends State<ParameterInfoCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'What do these parameters mean?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Pallet.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Pallet.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildParameterInfo(
                    header: 'x-authentication-api-key',
                    name: 'API Key',
                    description:
                        'Unique key provided by the TruVideo team. Used to identify your application when making API requests.',
                    icon: Icons.vpn_key_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildParameterInfo(
                    header: 'Secret Key',
                    name: 'Secret Key',
                    description: 'Used to generate your unique signature.',
                    icon: Icons.lock_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildParameterInfo(
                    header: 'x-multitenant-external-id',
                    name: 'External ID',
                    description:
                        'Subaccount identifier configured by the Partner. Required for multitenant purposes.',
                    icon: Icons.business_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildParameterInfo(
                    header: 'x-authentication-signature',
                    name: 'Security Signature',
                    description:
                        'A unique digital stamp created using your Secret Key. This proves the request really came from you and hasn\'t been tampered with.',
                    icon: Icons.fingerprint_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildParameterInfo(
                    header: 'timestamp',
                    name: 'Secure Timestamp',
                    description:
                        'The exact date and time the request was made. This ensures the request is recent (within 30 minutes) for security.',
                    icon: Icons.access_time_rounded,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterInfo({
    required String header,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Pallet.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              header,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
    );
  }
}
