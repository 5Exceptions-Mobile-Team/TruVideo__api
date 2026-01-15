import 'package:flutter/material.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/upload_step_description_card.dart';

class StepDescriptions {
  static UploadStepDescriptionCard step1() {
    return UploadStepDescriptionCard(
      stepNumber: 1,
      stepTitle: 'Start Upload',
      method: 'POST',
      endpoint: '/upload/start',
      description:
          'Tell the server you want to upload a file. Think of it like checking in at a post office - you tell them what you\'re sending, and they give you a tracking number and special labels for your package. You provide basic file info (type, title, creator) and receive a unique upload ID plus special upload links.',
      icon: Icons.play_arrow_rounded,
      color: Pallet.primaryColor,
      details: [
        StepDetail(
          title: 'Creates Your Upload Session',
          description:
              'The server creates a unique tracking number (upload ID) for your file. This ID follows your upload throughout the entire process, like a package tracking number.',
          icon: Icons.create_new_folder_rounded,
          color: Pallet.primaryColor,
        ),
        StepDetail(
          title: 'Gives You Special Upload Links',
          description:
              'You receive temporary links that let you upload directly to the cloud. These links expire after 20 minutes for security - like a ticket that\'s only valid for a short time.',
          icon: Icons.link_rounded,
          color: Colors.orange,
        ),
        StepDetail(
          title: 'Handles Large Files',
          description:
              'Large files can be split into smaller pieces (like sending a big package in multiple boxes). This makes uploads faster and more reliable - if one piece fails, you only resend that piece.',
          icon: Icons.pie_chart_rounded,
          color: Colors.purple,
        ),
        StepDetail(
          title: 'Adds File Information',
          description:
              'Provide details about your file: what type it is (video, image, etc.), a title, creator name, and optional tags. This helps organize and find your files later.',
          icon: Icons.info_rounded,
          color: Colors.teal,
        ),
      ],
    );
  }

  static UploadStepDescriptionCard step2() {
    return UploadStepDescriptionCard(
      stepNumber: 2,
      stepTitle: 'Upload Parts',
      method: 'PUT',
      endpoint: 'Special Upload Link (Direct to Cloud)',
      description:
          'Now you actually send your file to the cloud using the special links from Step 1. After each piece uploads successfully, you get a receipt (a unique code) confirming it arrived safely. Keep these receipts - you\'ll need them in Step 3 to prove everything was delivered.',
      icon: Icons.cloud_upload_rounded,
      color: Colors.orange,
      details: [
        StepDetail(
          title: 'Direct Cloud Upload',
          description:
              'Your files go straight to the cloud storage, taking the fastest route possible. It\'s like having a direct express lane instead of going through multiple stops.',
          icon: Icons.cloud_rounded,
          color: Colors.blue,
        ),
        StepDetail(
          title: 'Delivery Receipts',
          description:
              'After each piece uploads, you get a unique receipt code. This proves the piece arrived correctly and wasn\'t damaged during transfer. Save all receipts for Step 3.',
          icon: Icons.verified_rounded,
          color: Pallet.successColor,
        ),
        StepDetail(
          title: 'Faster with Parallel Uploads',
          description:
              'Multiple pieces can upload at the same time (in parallel), dramatically speeding up large file uploads. It\'s like having multiple delivery trucks instead of one.',
          icon: Icons.speed_rounded,
          color: Colors.purple,
        ),
        StepDetail(
          title: 'Track Progress',
          description:
              'Watch your upload progress in real-time. If any piece fails, you can retry just that piece without starting over - saving time and bandwidth.',
          icon: Icons.track_changes_rounded,
          color: Colors.teal,
        ),
      ],
    );
  }

  static UploadStepDescriptionCard step3() {
    return UploadStepDescriptionCard(
      stepNumber: 3,
      stepTitle: 'Complete Upload',
      method: 'POST',
      endpoint: '/upload/{uploadId}/complete',
      description:
          'After all pieces are uploaded, tell the server "I\'m done!" and show it all your receipts from Step 2. The server checks that every piece arrived correctly. If everything matches, it starts processing your file (like developing a photo). You\'ll get a confirmation that processing has started.',
      icon: Icons.check_circle_outline_rounded,
      color: Pallet.successColor,
      details: [
        StepDetail(
          title: 'Verification Check',
          description:
              'The server compares your receipts with what it received. This ensures nothing was lost or corrupted during upload - like counting all the boxes to make sure the complete package arrived.',
          icon: Icons.verified_user_rounded,
          color: Pallet.successColor,
        ),
        StepDetail(
          title: 'Background Processing',
          description:
              'Once verified, the server starts working on your file in the background - creating thumbnails, extracting info, and preparing it for use. This happens automatically.',
          icon: Icons.sync_rounded,
          color: Colors.orange,
        ),
        StepDetail(
          title: '"Accepted" Response',
          description:
              'You\'ll get an "Accepted" response meaning the server received everything and started processing. It\'s like a "your order is being prepared" message at a restaurant.',
          icon: Icons.hourglass_empty_rounded,
          color: Colors.blue,
        ),
        StepDetail(
          title: 'All Receipts Required',
          description:
              'You must include every receipt from Step 2. If any are missing or incorrect, the completion will fail - ensuring your file is complete and intact.',
          icon: Icons.checklist_rounded,
          color: Colors.purple,
        ),
      ],
    );
  }

  static UploadStepDescriptionCard step4() {
    return UploadStepDescriptionCard(
      stepNumber: 4,
      stepTitle: 'Check Status',
      method: 'GET',
      endpoint: '/upload/{uploadId}',
      description:
          'Check if your file is ready to use. The status will be: "Still Processing" (wait a bit longer), "Completed" (ready to use!), or "Failed" (something went wrong). Keep checking until you get a final answer. When complete, you\'ll receive the link to your uploaded file.',
      icon: Icons.verified_rounded,
      color: Colors.blue,
      details: [
        StepDetail(
          title: 'Status Updates',
          description:
              'Three possible statuses: "Still Processing" (server is working on it), "Completed" (your file is ready), or "Failed" (check what went wrong and try again).',
          icon: Icons.info_outline_rounded,
          color: Colors.blue,
        ),
        StepDetail(
          title: 'Don\'t Skip This Step',
          description:
              'This step is important! Step 3 only confirms processing started, not when it finishes. Always check status to know when your file is truly ready to use.',
          icon: Icons.warning_rounded,
          color: Pallet.warningColor,
        ),
        StepDetail(
          title: 'Keep Checking',
          description:
              'Since processing happens in the background, check the status every few seconds until you get "Completed" or "Failed". Small files process quickly, large videos take longer.',
          icon: Icons.refresh_rounded,
          color: Colors.purple,
        ),
        StepDetail(
          title: 'Success!',
          description:
              'When status shows "Completed", you\'ll receive the final link to your file plus all its details (size, duration, etc.). Your upload is done and ready to use!',
          icon: Icons.done_all_rounded,
          color: Pallet.successColor,
        ),
      ],
    );
  }
}
