import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user_model.dart';

class UserApiService {
  // Base UR
    static const String _baseUrl = "http://172.16.27.119:8000/api";

    // Endpoints
    static const String _register = "/user/register";
    static const String _login = "/user/login";
    static const String _1sendotp = "/user/forgot-password";
    static const String _2verifyotp = "/user/verify-otp";
    static const String _3reset = "/user/reset-password";
    static const String _profileEndpoint = "$_baseUrl/user/profile";
    static const String updateProfile = "$_baseUrl/user/updateProfile";

    //learderboard
    static const String leaderBoardApi = "${_baseUrl}/user/leaderBoard";


    //diet
    static const String dietlist = "$_baseUrl/user/dietPlans";
    static String mealList(int dietPlanId) => "$_baseUrl/user/dietMeals/$dietPlanId";
    static String mealDetails(int mealId) => "$_baseUrl/user/meal/$mealId";

    //workout
    static const quickworkout = "$_baseUrl/user/quickWorkouts";
    static const String focusArea = "$_baseUrl/user/focusAreas";
    static const String workoutlist = "$_baseUrl/user/workouts";
    static String focusAreaWorkout(int categotyid) => "$_baseUrl/user/workouts/focus/$categotyid";
    static String workoutdetails(int workoutid) => "$_baseUrl/user/workoutExe/$workoutid";

    //userworkout
    static const String startworkout = "$_baseUrl/user/startWorkout";
    static String getExercises(int workoutid) => "$_baseUrl/user/getExercises?workout_id=$workoutid";
    static String getAiExercises(int aiworkoutid) => "$_baseUrl/user/getExercises?ai_workout_id=$aiworkoutid";
    static const String updateExeProgress = "$_baseUrl/user/updateExeProgress";
    static const String todayWorkouts = "$_baseUrl/user/todayWorkouts";
    static String resumeworkout(String sessionId) => "$_baseUrl/user/resumeWorkout/$sessionId";

    // ai
    static const String aiworkoutdetails = "$_baseUrl/user/aiWorkout";
    static String aiWorkoutdetails(int wokoutid) => "$_baseUrl/user/aiWorkoutExercises/$wokoutid";
    static const String generateWorkout = "$_baseUrl/user/generate/AIWorkout";
    static String aiWorkoutdetailsafterCreation(int wokoutid) => "$_baseUrl/user/getAiWorkoutDetail/$wokoutid";


    //exercise
    static String exercisedetails(int exerciseid) => "$_baseUrl/user/exercise/$exerciseid";

    //injury
    static String injurylistbyfocusarea(int injuryid) => "$_baseUrl/user/injuries/$injuryid";
    static String injuryDeatils(int injuryid) => "$_baseUrl/user/injury/$injuryid";
    static const String injurylist = "$_baseUrl/user/injuries";


    // feedback
    static const feeedbacklist = "$_baseUrl/user/feedback";
    static const sendfeedack = "$_baseUrl/user/insertFeedback";

    //progress
    static const progresstrack = "$_baseUrl/user/progress";
    static const history = "$_baseUrl/user/history";
    static const weeklystatus = "$_baseUrl/user/weeklyStatus";
    static const finsihworkout = "$_baseUrl/user/finishWorkout";

    // goal
    static const goals = "$_baseUrl/user/goals";

    //ai deit
    static const aiDiet = "$_baseUrl/user/aiDiet";
    static String aiDietPlan(int id) => "$_baseUrl/user/aiDietPlan/$id";
    static String genarateDiet = "$_baseUrl/user/generate/AIDiet";

    //progress track
    static const weeklyReport = "$_baseUrl/user/weeklyReport";
    static const weeklyGraph = "$_baseUrl/user/weeklyGraph";
    static const aiReport = "$_baseUrl/user/aiReport";




    static Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }

    static Future<Map<String, dynamic>> getUserSession() async {
      final prefs = await SharedPreferences.getInstance();

      return {
        "token": prefs.getString('token'),
        "user_id": prefs.getInt('user_id'),
        "user_name": prefs.getString('user_name'),
        "user_email": prefs.getString('user_email'),
      };
    }

    static Future<User?> registerUser(User user) async {
      try {
        final Uri url = Uri.parse(_baseUrl + _register);

        final http.Response response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(user.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          return User.fromJson(data['data'] ?? data);
        } else {
          print("❌ Register failed: ${response.body}");
          return null;
        }
      } catch (e) {
        print("⚠️ Error registering user: $e");
        return null;
      }
    }

    static Future<bool> login({
      required String email,
      required String password,
    }) async
    {
      try {
        final url = Uri.parse(_baseUrl + _login);

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "user_email": email,
            "user_password": password,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            await prefs.setString('token', data['token']);
            await prefs.setInt('user_id', data['data']['user_id']);
            await prefs.setString('user_name', data['data']['user_name']);
            await prefs.setString('user_email', data['data']['user_email']);

            return true;
          }
        }

        return false;
      } catch (e) {
        print("❌ Login error: $e");
        return false;
      }
    }

    static Future<int?> getUserId() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('user_id');
    }

    static Future<void> logout() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }

    static Future<bool> isLoggedIn() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token') != null;
    }

    Future<String?> forgotPassword(String userEmail) async {
      final url = Uri.parse("$_baseUrl$_1sendotp"); // ✅ Fixed URL

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_email": userEmail}),
        );

        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // print("Success: ${data['message']}");
          return data['message'];
        } else {
          print("Error: ${data['message']}");
          return null;
        }
      } catch (e) {
        print("Request failed: $e");
        return null;
      }
    }

    static Future<Map<String, dynamic>> verifyOtp({
      required String email,
      required int otp,
    }) async
    {
      final Uri url = Uri.parse("$_baseUrl$_2verifyotp");

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_email": email,
            "otp": otp,
          }),
        );

        if (response.statusCode == 200) {
          // Convert JSON response to a Map
          final Map<String, dynamic> data = jsonDecode(response.body);
          return data;
        } else {
          // Handle non-200 responses
          return {
            "success": false,
            "message": "Server error: ${response.statusCode}"
          };
        }
      } catch (e) {
        // Handle connection errors
        return {"success": false, "message": "Error: $e"};
      }
    }

    static Future<Map<String, dynamic>> resetPassword({
      required String email,
      required String password,
      required String passwordConfirmation,
    }) async
    {
      final Uri url = Uri.parse(_baseUrl + _3reset);

      final Map<String, dynamic> body = {
        "user_email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };


      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          // Assuming API always returns JSON
          final Map<String, dynamic> data = jsonDecode(response.body);
          return data; // e.g., {"success": true, "message": "Password reset successfully"}
        } else {
          // Handle API errors
          return {
            "success": false,
            "message": "Failed with status code: ${response.statusCode}"
          };
        }
      } catch (e) {
        // Handle connection or decoding errors
        return {"success": false, "message": e.toString()};
      }
    }

    static Future<Map<String, dynamic>?> getUserProfile() async {
      try {
        final token = await getToken();

        final url = Uri.parse(_profileEndpoint);

        final response = await http.get(
          url,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        // print("STATUS: ${response.statusCode}");
        // print("BODY: ${response.body}");

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          if (jsonData['success'] == true) {
            return jsonData['data'];
          }
        }

        return null;
      } catch (e) {
        print("Error fetching user profile: $e");
        return null;
      }
    }

    static Future<bool> updateUserProfile({
      String? userName,
      String? userPhone,
      String? userCity,
      String? userWeight,
      String? userHeight,
      File? userImageFile, // <-- use File instead of String
    }) async
    {
      final token = await getToken();
      if (token == null) {
        print("Token not found");
        return false;
      }

      final uri = Uri.parse(updateProfile);

      // Create MultipartRequest
      var request = http.MultipartRequest('POST', uri);

      // Add text fields if not null
      if (userName != null && userName.isNotEmpty) request.fields['user_name'] = userName;
      if (userPhone != null && userPhone.isNotEmpty) request.fields['user_phone'] = userPhone;
      if (userCity != null && userCity.isNotEmpty) request.fields['user_city'] = userCity;
      if (userWeight != null && userWeight.isNotEmpty) request.fields['user_weight'] = userWeight;
      if (userHeight != null && userHeight.isNotEmpty) request.fields['user_height'] = userHeight;

      // Add image file if provided
      if (userImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'user_image', // must match your backend field name
          userImageFile.path,
        ));
      }

      // Add headers (e.g., auth)
      request.headers['Authorization'] = 'Bearer $token';

      try {
        final response = await request.send();

        // print("Status Code: ${response.statusCode}");
        final respStr = await response.stream.bytesToString();
        // print("Response: $respStr");

        return response.statusCode == 200;
      } catch (e) {
        print("Error: $e");
        return false;
      }
    }

    static Future<List<dynamic>> getLeaderBoard() async {
      try {
        String? token = await getToken();

        final response = await http.get(
          Uri.parse(leaderBoardApi),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // print(data);
          if (data['success'] == true) {
            return data['user_ranks'];
          }
        }

        return [];
      } catch (e) {
        print("Leaderboard Error: $e");
        return [];
      }
    }

    static Future<List<Map<String, dynamic>>> getDietPlans() async {
      try {
        String? token = await getToken();

        final response = await http.get(
          Uri.parse(dietlist),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);

          if (jsonData['success'] == true) {
            final List<dynamic> data = jsonData['data'];
            // cast each item to Map<String, dynamic>
            return data.map((e) => e as Map<String, dynamic>).toList();
          } else {
            throw Exception("Failed to fetch diet plans: ${jsonData['message']}");
          }
        } else {
          throw Exception("Server error: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception("Error fetching diet plans: $e");
      }
    }

    static Future<Map<String, dynamic>> fetchMeals({required int dietPlanId}) async {
      final token = await getToken(); // Get your token
      final String endpoint = mealList(dietPlanId);

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData; // Return the full JSON as a Map
      } else {
        throw Exception('Failed to fetch meals with status code: ${response.statusCode}');
      }
    }

    static Future<Map<String, dynamic>> fetchMealDetails({required int mealId}) async {
      final token = await getToken(); // Get your token
      final String endpoint = mealDetails(mealId);

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch meal details with status code: ${response.statusCode}');
      }
    }

    // workout
    static Future<List<dynamic>> getQuickWorkouts() async {
      try {
        String? token = await getToken();

        final response = await http.get(
          Uri.parse(quickworkout),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            return data['data']; // returning workout list
          }
        }

        return [];
      } catch (e) {
        print("Quick Workout Error: $e");
        return [];
      }
    }

    // Focus Areas
    static Future<List<dynamic>> getFocusAreas() async {
      try {
        String? token = await getToken();

        final response = await http.get(
          Uri.parse(focusArea),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            return data['data']; // returning focus areas list
          }
        }

        return [];
      } catch (e) {
        print("Focus Areas Error: $e");
        return [];
      }
    }

    static Future<List<dynamic>> getWorkoutList() async {
      try {
        String? token = await getToken();

        final response = await http.get(
          Uri.parse(workoutlist),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            return data['data']; // returning workouts list
          }
        }

        return [];
      } catch (e) {
        print("Workout List Error: $e");
        return [];
      }
    }

    static Future<Map<String, dynamic>> fetchFocusAreaWorkouts({
      required int categoryId,
    }) async
    {
      final token = await getToken(); // Get stored token
      final String endpoint = focusAreaWorkout(categoryId);

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch focus area workouts. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> fetchFeedbackList() async {
      final token = await getToken(); // Get stored token
      final String endpoint = feeedbacklist;

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch feedback list. Status code: ${response.statusCode}',
        );
      }
    }


    static Future<bool> sendFeedback({
      required String feedbackType,
      required String feedbackSubject,
      required String feedbackMessage,
    }) async
    {
      try {
        final token = await getToken();
        final userId = await getUserId();

        final response = await http.post(
          Uri.parse(sendfeedack),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "user_id": userId,
            "feedback_type": feedbackType,
            "feedback_subject": feedbackSubject,
            "feedback_message": feedbackMessage,
          }),
        );

        // print(response.statusCode);
        // print(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          return data["success"] == true;
        } else {
          return false;
        }
      } catch (e) {
        print("Send Feedback Error: $e");
        return false;
      }
    }


    static Future<Map<String, dynamic>?> getWorkoutDetails(int workoutId) async {
      try {
        final token = await getToken();

        final response = await http.get(
          Uri.parse(workoutdetails(workoutId)),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // print(response.statusCode);
        // print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data["success"] == true) {
            return data["data"]; // returning workout data
          }
        }

        return null;
      } catch (e) {
        print("Workout Details Error: $e");
        return null;
      }
    }

    static Future<Map<String, dynamic>?> getExerciseDetails(int exerciseId) async {
      try {
        final token = await getToken();

        final response = await http.get(
          Uri.parse(exercisedetails(exerciseId)),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // print(response.statusCode);
        // print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data["success"] == true) {
            return data["data"]; // returning exercise data
          }
        }

        return null;
      } catch (e) {
        print("Exercise Details Error: $e");
        return null;
      }
    }

    static Future<List<dynamic>?> getInjuryListByFocusArea(int injuryId) async {
      try {
        final token = await getToken();

        final response = await http.get(
          Uri.parse(injurylistbyfocusarea(injuryId)),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // print(response.statusCode);
        // print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data["success"] == true) {
            return data["data"]; // ✅ return LIST
          }
        }

        return null;
      } catch (e) {
        print("Injury List Error: $e");
        return null;
      }
    }

    static Future<Map<String, dynamic>?> getInjuryDetails(int injuryId) async {
      try {
        final token = await getToken();

        final response = await http.get(
          Uri.parse(injuryDeatils(injuryId)),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // print(response.statusCode);
        // print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data["success"] == true) {
            return data["data"]; // ✅ returning injury object
          }
        }

        return null;
      } catch (e) {
        print("Injury Details Error: $e");
        return null;
      }
    }

    static Future<List<dynamic>> getInjuryList() async {
      try {
        final token = await getToken();

        final response = await http.get(
          Uri.parse(injurylist),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // print(response.statusCode);
        // print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data["success"] == true) {
            return data["data"]; // ✅ returning list of injuries
          }
        }

        return [];
      } catch (e) {
        print("Injury List Error: $e");
        return [];
      }
    }


    // workout
    static Future<Map<String, dynamic>> fetchUserProgress() async {
      final token = await getToken(); // Get stored token
      final String endpoint = progresstrack;

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch user progress. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> fetchWorkoutHistory() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(history),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch workout history. Status code: ${response.statusCode}',
        );
      }
    }



    static Future<Map<String, dynamic>> fetchWeeklyStatus() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(weeklystatus),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch weekly status. Status code: ${response.statusCode}',
        );
      }
    }



    // user workout
    static Future<Map<String, dynamic>> startWorkout(int workoutId) async {
      final token = await getToken();

      final response = await http.post(
        Uri.parse(startworkout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "workout_id": workoutId,
        }),
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to start workout. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> fetchWorkoutExercises(int workoutId) async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(getExercises(workoutId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch workout exercises. Status code: ${response.statusCode}',
        );
      }
    }


    static Future<Map<String, dynamic>> starAitWorkout(int aiworkoutId) async {
      final token = await getToken();

      final response = await http.post(
        Uri.parse(startworkout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "ai_workout_id": aiworkoutId,
        }),
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to start workout. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<List<dynamic>> fetchAiWorkoutExercises(int aiworkoutId) async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(getAiExercises(aiworkoutId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Extract only exercise list
        return jsonData['data'];
      } else {
        throw Exception(
          'Failed to fetch workout exercises. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> updateExerciseProgress({
      required String sessionId,
      required int workoutId,
      required int exerciseId,
      required int exerciseOrder,
      int? setsCompleted,
      int? repsCompleted,
      int? exerciseDurationSec,
      required int isCompleted,
    }) async {

      final token = await getToken();

      Map<String, dynamic> body = {
        "session_id": sessionId,
        "workout_id": workoutId,
        "exercise_id": exerciseId,
        "exercise_order": exerciseOrder,
        "is_completed": isCompleted,
      };

      if (setsCompleted != null) body["sets_completed"] = setsCompleted;
      if (repsCompleted != null) body["reps_completed"] = repsCompleted;
      if (exerciseDurationSec != null) {
        body["exercise_duration_sec"] = exerciseDurationSec;
      }

      final response = await http.post(
        Uri.parse(updateExeProgress),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to update exercise progress. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> updateAiExerciseProgress({
      required String sessionId,
      required int aiworkoutId,
      required int exerciseId,
      required int exerciseOrder,
      int? setsCompleted,
      int? repsCompleted,
      int? exerciseDurationSec,
      required int isCompleted,
    }) async {

      final token = await getToken();

      Map<String, dynamic> body = {
        "session_id": sessionId,
        "ai_workout_id": aiworkoutId,
        "exercise_id": exerciseId,
        "exercise_order": exerciseOrder,
        "is_completed": isCompleted,
      };

      if (setsCompleted != null) body["sets_completed"] = setsCompleted;
      if (repsCompleted != null) body["reps_completed"] = repsCompleted;
      if (exerciseDurationSec != null) {
        body["exercise_duration_sec"] = exerciseDurationSec;
      }

      final response = await http.post(
        Uri.parse(updateExeProgress),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to update exercise progress. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> finishWorkout({
      required String sessionId,
    }) async {
      final token = await getToken();

      Map<String, dynamic> body = {
        "session_id": sessionId,
      };

      final response = await http.post(
        Uri.parse(finsihworkout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to finish workout. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> getTodayWorkouts() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(todayWorkouts),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to fetch today workouts. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> resumeWorkoutApi({
      required String sessionId,
    }) async {

      final token = await getToken();

      final response = await http.get(
        Uri.parse(resumeworkout(sessionId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;

      } else {
        throw Exception(
          'Failed to resume workout. Status code: ${response.statusCode}',
        );
      }
    }


    // ai
    static Future<List<Map<String, dynamic>>> getAiWorkoutDetails() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(aiworkoutdetails),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch AI workout details. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<List<Map<String, dynamic>>> getResumeWorkout(int workoutId) async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(aiWorkoutdetails(workoutId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch exercises. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> generateAIWorkout({
      required String goal,
      required String focusArea,
      required int duration,
      required String bodyType,
      required String difficulty, // ✅ Added parameter
    }) async {
      final token = await getToken();

      final response = await http.post(
        Uri.parse(generateWorkout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "goal": goal,
          "focus_area": focusArea,
          "duration": duration,
          "body_type": bodyType,
          "difficulty": difficulty, // ✅ Added to request body
        }),
      );

      print(response.statusCode);
      print('Response body: "${response.body}"');
      print('Response headers: ${response.headers}');


      if (response.statusCode == 200) {
        // Guard against empty body
        if (response.body.isEmpty) {
          throw Exception('Server returned empty response.');
        }

        Map<String, dynamic> jsonData;
        try {
          jsonData = json.decode(response.body);
        } catch (e) {
          throw Exception('Invalid JSON from server: ${response.body}');
        }

        if (jsonData['status'] == true) {
          return jsonData;
        } else {
          throw Exception('Failed to generate AI workout: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to generate AI workout. Status code: ${response.statusCode}');
      }
    }


    //goal
    static Future<List<Map<String, dynamic>>> getGoals() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(goals),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch goals. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> getAiWorkoutFullDetails(int workoutId) async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(aiWorkoutdetailsafterCreation(workoutId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Since "data" is an object, not a list
        return Map<String, dynamic>.from(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch AI workout full details. Status code: ${response.statusCode}',
        );
      }
    }


    // ai diet
    static Future<List<Map<String, dynamic>>> getAiDietPlans() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(aiDiet),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch diet plans. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>> getAiDietPlanFullDetails(int dietPlanId) async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(aiDietPlan(dietPlanId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // "data" is an object (contains plan + days + meals)
        return Map<String, dynamic>.from(jsonData['data']);
      } else {
        throw Exception(
          'Failed to fetch AI diet plan full details. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<Map<String, dynamic>?> generateDiet({
      required String goal,
      required String bodyType,
      required int calories,
    }) async {
      try {
        final url = Uri.parse(_baseUrl + "/user/generate/AIDiet");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "goal": goal,
            "body_type": bodyType,
            "calories": calories,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['status'] == true) {
            return data['data']; // ✅ RETURN FULL DATA
          }
        }

        return null;
      } catch (e) {
        print("❌ Generate Diet error: $e");
        return null;
      }
    }


    // progress track

    static Future<Map<String, dynamic>> getWeeklyReport() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(weeklyReport),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return jsonData; // full response (current_week, previous_week, etc.)
      } else {
        throw Exception(
          'Failed to fetch weekly report. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<List<Map<String, dynamic>>> getWeeklyGraph() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(weeklyGraph),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        throw Exception(
          'Failed to fetch weekly graph. Status code: ${response.statusCode}',
        );
      }
    }

    static Future<String> getAiReport() async {
      final token = await getToken();

      final response = await http.get(
        Uri.parse(aiReport),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return jsonData['ai_feedback']; // only returning feedback string
      } else {
        throw Exception(
          'Failed to fetch AI report. Status code: ${response.statusCode}',
        );
      }
    }


}

