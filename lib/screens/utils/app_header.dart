import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_helper.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grab a byte',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
            // IconButton(
            //   onPressed: () async {
            //     if (authProvider.isAuthenticated) {
            //       // Navigate to profile screen with smooth transition
            //       Navigator.of(
            //         context,
            //       ).push(ProfilePageRoute(child: const ProfileScreen()));
            //     } else {
            //       // Show login screen
            //       await AuthHelper.showLoginScreen(context);
            //     }
            //   },
            //   icon: Icon(
            //     authProvider.isAuthenticated
            //         ? Icons.person
            //         : Icons.person_outline,
            //     color: Theme.of(context).iconTheme.color,
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
