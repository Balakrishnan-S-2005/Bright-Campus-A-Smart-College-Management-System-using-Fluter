import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Bright Path Connect",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF674AEF),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Welcome to Bright Path Connect!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF674AEF),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Bright Path Connect is a platform designed to bring people together and foster community connections. "
                        "Our mission is to create a space where individuals can access resources, network, and collaborate on "
                        "projects that will drive positive change in their communities.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Features",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF674AEF),
                ),
              ),
              SizedBox(height: 10),
              _buildFeatureList(),
              SizedBox(height: 20),
              Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF674AEF),
                ),
              ),
              SizedBox(height: 10),
              _buildContactInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    List<String> features = [
      "Connect with like-minded individuals",
      "Access educational resources",
      "Collaborate on impactful projects",
      "Participate in events and workshops",
      "Build a network that supports your goals",
    ];

    return Column(
      children: features.map((feature) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Color(0xFF674AEF)),
            title: Text(feature, style: TextStyle(fontSize: 16)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF674AEF)),
              title: Text("abn.miniproject@gmail.com", style: TextStyle(fontSize: 16)),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF674AEF)),
              title: Text("91+9500026518", style: TextStyle(fontSize: 16)),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.language, color: Color(0xFF674AEF)),
              title: Text("www.abnProjects.com", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}