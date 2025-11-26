import 'package:flutter/material.dart';
import 'dart:math' as math;

/// About Screen - Exact Figma implementation from About.tsx
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bubble 04 - Yellow bubble at bottom right, rotated 110deg
          // Figma: left: calc(41.67% - 7.92px), top: 495.4px, rotate: 110deg
          Positioned(
            left: MediaQuery.of(context).size.width * 0.4167 - 7.92,
            top: 495.4,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(opacity: opacity, child: child);
              },
              child: Transform.rotate(
                angle: 110 * math.pi / 180, // 110 degrees
                child: SizedBox(
                  width: 353.53,
                  height: 442.65,
                  child: CustomPaint(
                    size: const Size(353.53, 442.65),
                    painter: _Bubble04Painter(),
                  ),
                ),
              ),
            ),
          ),

          // Bubble 02 - Yellow bubble at top left, rotated 235.784deg
          // Figma: left: -115px, top: -254px, rotate: 235.784deg
          Positioned(
            left: -115,
            top: -254,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(opacity: opacity, child: child);
              },
              child: Transform.rotate(
                angle: 235.784 * math.pi / 180, // 235.784 degrees
                child: SizedBox(
                  width: 373.531,
                  height: 442.65,
                  child: CustomPaint(
                    size: const Size(373.531, 442.65),
                    painter: _Bubble02Painter(),
                  ),
                ),
              ),
            ),
          ),

          // Bubble 01 - Black bubble at top left, rotated 240deg
          // Figma: left: -148.17px, top: -290.48px, rotate: 240deg
          Positioned(
            left: -148.17,
            top: -290.48,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(opacity: opacity, child: child);
              },
              child: Transform.rotate(
                angle: 240 * math.pi / 180, // 240 degrees
                child: SizedBox(
                  width: 402.871,
                  height: 442.65,
                  child: CustomPaint(
                    size: const Size(402.871, 442.65),
                    painter: _Bubble01Painter(),
                  ),
                ),
              ),
            ),
          ),

          // Back button - Figma: left: 10px, top: 50px, size: 50x53
          Positioned(
            left: 10,
            top: 50,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 50,
                height: 53,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // "About" title - Figma: left: calc(16.67% + 2px), top: 48px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + 2,
            top: 48,
            child: const Text(
              'About',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.52,
              ),
            ),
          ),

          // Scrollable Frame - Figma: left: calc(8.33% - 10.5px), top: 155px, h: 680px, w: 355px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.0833 - 10.5,
            top: 155,
            child: SizedBox(
              width: 355,
              height: 680,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About District 306 section
                    _buildAboutDistrictSection(),
                    const SizedBox(height: 22),

                    // Our Mission section
                    _buildMissionSection(),
                    const SizedBox(height: 22),

                    // Our Vision section
                    _buildVisionSection(),
                    const SizedBox(height: 22),

                    // What We Do section
                    _buildWhatWeDoSection(),
                    const SizedBox(height: 22),

                    // Our Structure section
                    _buildStructureSection(),
                    const SizedBox(height: 22),

                    // Our Clubs section
                    _buildClubsSection(),
                    const SizedBox(height: 22),

                    // Why Join Us section
                    _buildWhyJoinSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // App version box - Figma: left: calc(8.33% + 4.5px), top: 879px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.0833 + 4.5,
            top: 845,
            child: Container(
              width: 332,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x1A000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'App version',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1.00.0',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar - Figma: left: calc(33.33% - 3px), top: 863px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.3333 - 3,
            bottom: 10,
            child: Container(
              width: 145.848,
              height: 5.442,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // About District 306 - Figma: box h:141.177, rounded:15
  Widget _buildAboutDistrictSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'About District 306',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'LEO District 306 is a leading youth-led service community in Sri Lanka, uniting passionate young leaders committed to personal growth, community service, and positive impact.\n Built on Leadership, Experience, and Opportunity, we empower Leos to develop real leadership skills and contribute meaningfully through humanitarian and youth development initiatives.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }

  // Our Mission - Figma: box h:62, rounded:15
  Widget _buildMissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Our Mission',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'To empower young individuals to become responsible leaders who create sustainable and meaningful change in their communities.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }

  // Our Vision - Figma: box h:62, rounded:15
  Widget _buildVisionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Our Vision',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'A generation of youth equipped with compassion, leadership, and skills to build a better future for Sri Lanka and the world.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }

  // What We Do - Figma: box h:189, rounded:15
  Widget _buildWhatWeDoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'What We Do',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'District 306 carries out:',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 4),
              _BulletPoint('Community service projects that uplift underserved communities'),
              _BulletPoint('Youth leadership and skill-building programs'),
              _BulletPoint('Environmental protection and sustainability initiatives'),
              _BulletPoint('Health and wellness campaigns'),
              _BulletPoint('Fundraisers and charity drives'),
              _BulletPoint('District-wide conventions, training sessions, and competitions'),
              SizedBox(height: 8),
              Text(
                'These activities help Leos enhance teamwork, public speaking, project management, and organizational skills.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Our Structure - Figma: box h:126, rounded:15
  Widget _buildStructureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Our Structure',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'The district is guided by:',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 4),
              _BulletPoint('District President & Executive Committee'),
              _BulletPoint('Regional and Zone Chairpersons'),
              _BulletPoint('Advisors, Coordinators, and Club Officers'),
              SizedBox(height: 8),
              Text(
                'Together, they support all Leo clubs within District 306, ensuring smooth operations, strong collaboration, and impactful project outcomes.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Our Clubs - Figma: box h:76, rounded:15
  Widget _buildClubsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Our Clubs',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'District 306 is composed of multiple Leo clubs across different cities and regions. Each club carries out unique service activities while contributing to the district\'s common goals.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }

  // Why Join Us - Figma: box h:140, rounded:15
  Widget _buildWhyJoinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Why Join Us?',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2.58,
            ),
          ),
        ),
        Container(
          width: 353,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Being a Leo means:',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 4),
              _BulletPoint('Becoming a leader'),
              _BulletPoint('Gaining real-world experience'),
              _BulletPoint('Meeting inspiring youth'),
              _BulletPoint('Serving communities that need help'),
              _BulletPoint('Being part of an international movement'),
              SizedBox(height: 8),
              Text(
                'District 306 is more than a youth organization - it\'s a family of passionate changemakers.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Bullet point widget
class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.33,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bubble 01 - Black bubble (p36b3a180 path)
// SVG path: "M201.436 39.7783C296.874 -90.0363 402.871 129.964 402.871 241.214C402.871 352.464 312.686 442.65 201.436 442.65C90.1858 442.65 0 352.464 0 241.214C0 129.964 105.998 169.593 201.436 39.7783Z"
class _Bubble01Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 403;
    final scaleY = size.height / 443;

    final path = Path();
    path.moveTo(201.436 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      296.874 * scaleX, -90.0363 * scaleY,
      402.871 * scaleX, 129.964 * scaleY,
      402.871 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      402.871 * scaleX, 352.464 * scaleY,
      312.686 * scaleX, 442.65 * scaleY,
      201.436 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      90.1858 * scaleX, 442.65 * scaleY,
      0, 352.464 * scaleY,
      0, 241.214 * scaleY,
    );
    path.cubicTo(
      0, 129.964 * scaleY,
      105.998 * scaleX, 169.593 * scaleY,
      201.436 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bubble 02 - Yellow bubble (p2c5a2d80 path)
// SVG path: "M172.096 39.7783C267.534 -90.0363 373.531 129.964 373.531 241.214C373.531 352.464 283.346 442.65 172.096 442.65C60.8459 442.65 8.63746 346.944 0.53979 245.526C-7.55788 144.107 76.6577 169.593 172.096 39.7783Z"
class _Bubble02Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 374;
    final scaleY = size.height / 443;

    final path = Path();
    path.moveTo(172.096 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      267.534 * scaleX, -90.0363 * scaleY,
      373.531 * scaleX, 129.964 * scaleY,
      373.531 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      373.531 * scaleX, 352.464 * scaleY,
      283.346 * scaleX, 442.65 * scaleY,
      172.096 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      60.8459 * scaleX, 442.65 * scaleY,
      8.63746 * scaleX, 346.944 * scaleY,
      0.53979 * scaleX, 245.526 * scaleY,
    );
    path.cubicTo(
      -7.55788 * scaleX, 144.107 * scaleY,
      76.6577 * scaleX, 169.593 * scaleY,
      172.096 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bubble 04 - Yellow bubble at bottom (p2ec28100 path)
// SVG path: "M162.881 39.7783C253.208 -90.0363 353.53 129.964 353.53 241.214C353.53 352.464 268.173 442.65 162.881 442.65C57.5878 442.65 8.17495 346.944 0.510886 245.526C-7.15317 144.107 72.5529 169.593 162.881 39.7783Z"
class _Bubble04Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 354;
    final scaleY = size.height / 443;

    final path = Path();
    path.moveTo(162.881 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      253.208 * scaleX, -90.0363 * scaleY,
      353.53 * scaleX, 129.964 * scaleY,
      353.53 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      353.53 * scaleX, 352.464 * scaleY,
      268.173 * scaleX, 442.65 * scaleY,
      162.881 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      57.5878 * scaleX, 442.65 * scaleY,
      8.17495 * scaleX, 346.944 * scaleY,
      0.510886 * scaleX, 245.526 * scaleY,
    );
    path.cubicTo(
      -7.15317 * scaleX, 144.107 * scaleY,
      72.5529 * scaleX, 169.593 * scaleY,
      162.881 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
