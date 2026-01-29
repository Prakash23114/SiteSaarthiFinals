import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EngineerDashboardPage extends StatefulWidget {
  const EngineerDashboardPage({super.key});

  @override
  State<EngineerDashboardPage> createState() => _EngineerDashboardPageState();
}

class _EngineerDashboardPageState extends State<EngineerDashboardPage> {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  bool loading = true;
  String errorMsg = "";

  String token = "";
  Map<String, dynamic>? authUser;

  List<Map<String, dynamic>> projects = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadAuth();
    await _fetchProjects();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("authToken") ?? "";
    final raw = prefs.getString("authUser");
    if (raw != null) authUser = jsonDecode(raw);
  }

  Future<void> _fetchProjects() async {
    if (token.isEmpty) {
      setState(() {
        loading = false;
        errorMsg = "Token missing. Please login again.";
      });
      return;
    }

    try {
      setState(() {
        loading = true;
        errorMsg = "";
      });

      final url = Uri.parse("$baseUrl/projects");
      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (res.body.isEmpty) throw "Empty response from server";
      final data = jsonDecode(res.body);

      if (res.statusCode >= 400) {
        throw data["message"] ?? "Failed to load projects";
      }

      final List list = (data["projects"] ?? []) as List;
      final mapped = list.map((e) => Map<String, dynamic>.from(e)).toList();

      setState(() {
        projects = mapped;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMsg = "Network error: $e";
      });
    }
  }

  // helpers
  String _projectId(Map<String, dynamic> p) {
    if (p["_id"] != null) return p["_id"].toString();
    if (p["id"] != null) return p["id"].toString();
    return "";
  }

  String _projectName(Map<String, dynamic> p) {
    return (p["projectName"] ?? p["name"] ?? "-").toString();
  }

  String _projectLocation(Map<String, dynamic> p) {
    final loc = p["location"] ?? {};
    final taluka = (loc["taluka"] ?? "").toString();
    final district = (loc["district"] ?? "").toString();
    final state = (loc["state"] ?? "").toString();
    final parts =
        [taluka, district, state].where((e) => e.trim().isNotEmpty).toList();
    return parts.isEmpty ? "-" : parts.join(", ");
  }

  /// ✅ Dashboard projects (status calculation)
  List<Map<String, dynamic>> get dashboardProjects {
    // currently backend does not provide dpr/material counts
    // so default rule: status always ON TRACK
    // later you can update from real API fields
    return projects.map((p) {
      return {
        ...p,
        "status": "On Track", // future: calculate from DPR/materials
        "dpr": true,
        "materialsCount": 0,
      };
    }).toList();
  }

  int get onTrack =>
      dashboardProjects.where((p) => p["status"] == "On Track").length;

  int get attention =>
      dashboardProjects.where((p) => p["status"] == "Attention Needed").length;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B3C5D)),
        ),
      );
    }

    if (errorMsg.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 48, color: Color(0xFFF59E0B)),
                const SizedBox(height: 10),
                const Text(
                  "Failed to load dashboard",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _fetchProjects,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3C5D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text("Engineer Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.access_time, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("Shift started at 08:30 AM",
                      style: TextStyle(fontSize: 11, color: Colors.grey))
                ],
              ),
              const SizedBox(height: 20),

              /// UTILIZATION CARD (static for now)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4338CA)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("UTILIZATION",
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    const Text("92%",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: 0.92,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 6,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// STATS GRID
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                      title: "On Track",
                      value: onTrack.toString(),
                      icon: Icons.check_circle,
                      bg: const Color(0xFFD1FAE5),
                      fg: const Color(0xFF059669)),
                  StatCard(
                      title: "Attention",
                      value: attention.toString(),
                      icon: Icons.warning,
                      bg: const Color(0xFFFFFBEB),
                      fg: const Color(0xFFD97706)),
                  StatCard(
                      title: "Projects",
                      value: dashboardProjects.length.toString(),
                      icon: Icons.grid_view,
                      bg: const Color(0xFFDBEAFE),
                      fg: const Color(0xFF2563EB)),
                  const StatCard(
                      title: "Quality",
                      value: "✓",
                      icon: Icons.check_circle,
                      bg: Color(0xFFDCFCE7),
                      fg: Color(0xFF16A34A)),
                ],
              ),

              const SizedBox(height: 24),

              /// ATTENTION RADAR
              const Text("🚨 Attention Radar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: dashboardProjects.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No assigned projects",
                            style: TextStyle(color: Colors.grey)),
                      )
                    : Column(
                        children: dashboardProjects.map((p) {
                          final name = _projectName(p);
                          final location = _projectLocation(p);

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text(location,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                          const SizedBox(height: 3),
                                          Text("Project ID: ${_projectId(p)}",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFD1FAE5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text("ON TRACK",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF047857))),
                                    )
                                  ],
                                ),
                              ),
                              if (p != dashboardProjects.last)
                                Divider(height: 1, color: Colors.grey.shade200)
                            ],
                          );
                        }).toList(),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bg;
  final Color fg;

  const StatCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.bg,
      required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }
}
