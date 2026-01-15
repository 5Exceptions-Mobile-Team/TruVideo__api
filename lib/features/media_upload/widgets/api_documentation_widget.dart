import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class ApiDocumentationWidget extends StatefulWidget {
  const ApiDocumentationWidget({super.key});

  @override
  State<ApiDocumentationWidget> createState() => _ApiDocumentationWidgetState();
}

class _ApiDocumentationWidgetState extends State<ApiDocumentationWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Pallet.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Pallet.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Pallet.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Pallet.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How Upload Works',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Pallet.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Understanding the upload process',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Pallet.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Pallet.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  
                  // Overview
                  Text(
                    'Simple Explanation',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Uploading files works in 4 easy steps. Imagine you\'re mailing a package - you tell the post office, send it, confirm it arrived, and check the tracking.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Pallet.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Step 1
                  _buildStep(
                    step: 1,
                    title: 'Start Upload',
                    description:
                        'You tell the server "I want to upload a file." The server creates a special session and gives you secure links (presigned URLs) - think of them as temporary keys that let you upload directly to cloud storage. These keys expire after 20 minutes for security.',
                    icon: Icons.play_arrow_rounded,
                    color: Pallet.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Step 2
                  _buildStep(
                    step: 2,
                    title: 'Upload Parts',
                    description:
                        'Your file gets sent in pieces (parts) directly to secure cloud storage. Large files are split into smaller chunks for faster uploads - like sending a book one chapter at a time. Each piece uses those secure links from step 1. You can upload multiple parts at the same time for even faster speeds.',
                    icon: Icons.cloud_upload_rounded,
                    color: Pallet.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Step 3
                  _buildStep(
                    step: 3,
                    title: 'Complete Upload',
                    description:
                        'Once all pieces are uploaded, you tell the server "I\'m done!" The server then checks that all pieces arrived correctly using digital signatures (like fingerprints for each piece). If everything matches, it puts the file together and starts processing it in the background.',
                    icon: Icons.check_circle_outline_rounded,
                    color: Pallet.successColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Step 4
                  _buildStep(
                    step: 4,
                    title: 'Check Status',
                    description:
                        'The server works on your file in the background (this is called "asynchronous processing"). You need to check back later to see when it\'s ready - just like tracking a package. The file isn\'t ready instantly, but you\'ll see updates as it processes.',
                    icon: Icons.verified_rounded,
                    color: Pallet.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  
                  // Key Concepts
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Pallet.cardBackgroundSubtle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Pallet.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 18,
                              color: Pallet.warningColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Key Concepts',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Pallet.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildConcept(
                          'Multipart Upload',
                          'Large files are split into smaller pieces (parts) for faster, more reliable uploads. Each part must be at least 5 MB, and you can upload up to 120 parts. Think of it like sending a book page by page instead of all at once.',
                        ),
                        const SizedBox(height: 12),
                        _buildConcept(
                          'Presigned URLs',
                          'Temporary secure links that let you upload directly to cloud storage without exposing your credentials. These links expire after 20 minutes for security - like a one-time-use key to a secure room.',
                        ),
                        const SizedBox(height: 12),
                        _buildConcept(
                          'Asynchronous Processing',
                          'After you finish uploading, the server processes your file in the background. This means it doesn\'t happen instantly - you need to check back later to see when it\'s ready. It\'s like ordering food: you place the order, then wait for it to be prepared.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reference
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Pallet.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Pallet.primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 16,
                          color: Pallet.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'For detailed technical documentation, visit the official API docs',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Pallet.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildStep({
    required int step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Step $step',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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

  Widget _buildConcept(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Pallet.primaryColor,
            shape: BoxShape.circle,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Pallet.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Pallet.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
