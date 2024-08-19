import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dierenasiel_android/authentication/authentication.dart';
import 'package:dierenasiel_android/helpers/constants.dart';
import 'package:dierenasiel_android/profile/view/view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UserProfileHeader(),
            Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _UserDetails(),
                    SizedBox(height: 20),
                    _EditButton(),
                    Padding(padding: EdgeInsets.all(8)),
                    _LogoutButton(),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class _UserProfileHeader extends StatelessWidget {
  const _UserProfileHeader();

  @override
  Widget build(BuildContext context) {
    final firstName =
        context.select((AuthenticationBloc bloc) => bloc.state.user.firstname);
    final lastName =
        context.select((AuthenticationBloc bloc) => bloc.state.user.lastname);

    String initials = '';

    initials += firstName.isNotEmpty ? firstName[0] : '';
    initials += lastName.isNotEmpty ? lastName[0] : '';

    return SizedBox(
      height: 275,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipPath(
            clipper: CurveClipper(), // Custom clipper for curved shape
            child: Container(
              height: 185,
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
            ),
          ),
          Positioned(
            top: 90,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: white,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileUpdatePage()),
                        );
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text('$firstName $lastName',
                    style: const TextStyle(
                      fontSize: 30,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _UserDetails extends StatelessWidget {
  const _UserDetails();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);
    final fullName = '${user.firstname} ${user.lastname}';

    return Column(
      children: [
        _UserInfoField(
          icon: Icons.person,
          label: 'Naam',
          value: fullName,
        ),
        const Padding(padding: EdgeInsets.all(8)),
        _UserInfoField(
          label: 'E-mailadres',
          value: user.email,
          icon: Icons.email,
        ),
        const Padding(padding: EdgeInsets.all(8)),
        const _UserInfoField(
          label: 'Wachtwoord',
          value: '********',
          icon: Icons.lock,
        ),
      ],
    );
  }
}

class _UserInfoField extends StatelessWidget {
  const _UserInfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
      ),
      tileColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProfileUpdatePasswordPage()),
          );
        },
        child: const Text('Wachtwoord wijzigen'),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: white,
        ),
        child: const Text('Logout'),
        onPressed: () {
          context.read<AuthenticationBloc>().add(AuthenticationLogoutPressed());
        },
      ),
    );
  }
}
