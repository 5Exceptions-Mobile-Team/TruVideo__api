import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/utils/app_text_styles.dart';

class UploadStepDescriptionCard extends StatelessWidget {
  final int stepNumber;
  final String stepTitle;
  final String method;
  final String endpoint;
  final String description;
  final List<StepDetail> details;
  final IconData icon;
  final Color color;

  const UploadStepDescriptionCard({
    super.key,
    required this.stepNumber,
    required this.stepTitle,
    required this.method,
    required this.endpoint,
    required this.description,
    required this.details,
    this.icon = Icons.api_rounded,
    this.color = Pallet.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step $stepNumber',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stepTitle,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Pallet.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Endpoint Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Pallet.cardBackgroundSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Pallet.glassBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMethodColor(method).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    method,
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getMethodColor(method),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    endpoint,
                    style: GoogleFonts.firaCode(
                      fontSize: 13,
                      color: Pallet.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Description
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Pallet.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          
          // Details
          if (details.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Pallet.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Points',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDetailItem(detail),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(StepDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pallet.cardBackgroundAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: detail.color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: detail.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              detail.icon,
              size: 18,
              color: detail.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.description,
                  style: AppTextStyles.bodyMedium(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return Pallet.successColor;
      case 'PUT':
        return Colors.orange;
      case 'GET':
        return Colors.blue;
      default:
        return Pallet.textSecondary;
    }
  }
}

class StepDetail {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  StepDetail({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
