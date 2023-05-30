import 'package:flutter/material.dart';
import 'package:lightmeter/environment.dart';
import 'package:lightmeter/generated/l10n.dart';
import 'package:lightmeter/utils/inherited_generics.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportIssueListTile extends StatelessWidget {
  const ReportIssueListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bug_report),
      title: Text(S.of(context).reportIssue),
      onTap: () {
        launchUrl(
          Uri.parse(context.get<Environment>().issuesReportUrl),
          mode: LaunchMode.externalApplication,
        );
      },
    );
  }
}
