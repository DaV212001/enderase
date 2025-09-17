import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      "no_providers_found": "No providers found",
      "top_rated": "Top Rated",
      "professional": "Professional",
      "nearby": "Nearby",
      "search": "Search Providers...",
      "no_categories_found": "No Categories Found",
      'step_personal_info': 'Personal Information',
      'step_contact_details': 'Contact Details',
      'step_address_info': 'Address Information',
      'step_profile_picture': 'Profile Picture',
      'name_required': 'Name is required',
      'phone_required': 'Phone number is required',
      'loading_city': 'Loading cities...',
      'loading_sub_city': 'Loading sub cities...',
      'load_failed_retry': 'Failed. Tap to retry',
      'woreda_required': 'Woreda is required',
      'house_number_required': 'House number is required',
      'pick_profile_picture': 'Pick Profile Picture',
      'previous': 'Previous',
      'next': 'Next',
      'login': 'Login',
      'valid_email': 'Enter a valid email.',
      'email': 'Email',
      'email_phone': 'Email/Phone Number',
      'password': 'Password',
      'password_requirement': 'Password must be at least 8 characters.',
      'confirm_pass': 'Confirm Password',
      'pass_not_match': "Passwords do not match",
      'password_must_have_one_uppercase':
          'Password must contain at least one uppercase',
      'password_must_have_one_lowercase':
          'Password must contain at least one lowercase',
      'password_must_have_one_number':
          'Password must contain at least one number',
      'password_must_have_one_special_character':
          'Password must contain at least one special character',
      'create_account': 'Create Account',
      'first_name_requirement': 'First name must be at least 2 characters.',
      'must_include_up_to_grand_father':
          'Enter your name up to your grandfather\'s',
      'full_name': 'Full Name (Up To Grandfather)',
      'last_name_requirement': 'Last name must be at least 2 characters.',
      'last_name': 'Last name',
      'phone_number': 'Phone Number',
      'invalid_phone': 'Invalid Phone Number',
      'no_trips_yet': 'No trips yet',
      'no_trips_description':
          'You haven\'t taken any trips yet. Let\'s get moving!',
      'no_routes_yet': 'No routes yet',
      'no_routes_found':
          'No routes found on the server, please check back later.',
      'refresh': 'Refresh',
      'subscribe_route': 'Subscribe to Route',
      'unnamed_stop': 'Unnamed Stop',
      'km_from_previous': 'km from previous',
      'my_wallet': 'My Wallet',
      'secondary_phone': 'Secondary Phone',
      'landline_phone': 'Landline Phone',
      'help_support': 'Help and Support',
      'about_us': 'About Us',
      'terms_conditions': 'Terms and Conditions',
      'privacy_policy': 'Privacy Policy',
      'logout': 'Log out',
      'no_account': 'Don\'t have an account? ',
      'have_account': 'Already have an account? ',
      'sign_up_here': 'Sign Up Here',
      'log_in_here': 'Log In Here',
      'no_internet': 'No Internet Connection',
      'no_internet_description':
          'It seems that your internet connection is turned off. Please turn it on and try again.',
      'retry': 'Retry',
      'check_connection':
          'Please check your internet connection and try again.',
      'internal_server_error': 'Internal Server Error',
      'internal_server_error_desc':
          'The server encountered an error and could not complete your request.',
      'service_unavailable': 'Service Unavailable',
      'service_unavailable_desc':
          'The service is temporarily unavailable. Please try again later.',
      'not_found': 'Not Found',
      'not_found_desc': 'The requested resource was not found on the server.',
      'gateway_timeout': 'Gateway Timeout',
      'gateway_timeout_desc':
          'The gateway did not receive a timely response from the upstream server.',
      'unauthorized': 'Unauthorized',
      'unauthorized_desc': 'You are not authorized to access this resource.',
      'forbidden': 'Forbidden',
      'forbidden_desc': 'You do not have permission to access this resource.',
      'too_many_requests': 'Too Many Requests',
      'too_many_requests_desc':
          'You have sent too many requests in a given amount of time.',
      'error': 'Error',
      'unknown_error': 'Unknown Error',
      'unexpected_error': 'An unexpected error occurred, please try later',
      'city': 'City',
      'sub_city': 'Sub City',
      'woreda': 'Woreda',
      'house_number': 'House number',
      'filters': 'Filters',
      'rating': 'Rating',
      'radius': 'Radius',
      'category': 'Category',
      'found': "Found (@amount)",
      "sort_by": 'Sort by',
      "name": "Name",
      "cert": "Certificates",
      "favorites": "Favorites",
      "remove_from_favorites": "Remove from Favorites",
      "remove_from_favorites_confirmation":
          "Are you sure you want to remove @name from your favorites?",
      "no_favorites_found": "No favorites found",
      "no_favorites_description":
          "You haven't added any providers to your favorites yet.",
      "remove": "Remove",
      "cancel": "Cancel",
      "my_bookings": "My Bookings",
      "no_bookings_found": "No bookings found",
      "no_bookings_description": "You haven't made any bookings yet.",
      "booking_id": "Booking #@id",
      "start_time": "Start Time",
      "end_time": "End Time",
      "provider_id": "Provider ID",
      "category_id": "Category ID",
      "notes": "Notes",
      "booking_details": "Booking Details",
      "created_at": "Created At",
      "pending": "Pending",
      "confirmed": "Confirmed",
      "cancelled": "Cancelled",
      "completed": "Completed",
      "yes": "Yes",
      "no": "No",

      // ===================== COMMON FIELDS =====================
      'size': 'Size',
      'areas': 'Areas',
      'areas.*': 'Area option',
      'tasks': 'Tasks',
      'tasks.*': 'Task',
      'photos': 'Photos',
      'photos.*': 'Photo',

      // ===================== CLEANER =====================
      'type_of_space': 'Type of space',
      'supplies_available': 'Supplies available',
      'pets_present': 'Pets present',

      // Enums
      'home': 'Home',
      'office': 'Office',
      'apartment': 'Apartment',
      'other': 'Other',
      'bedrooms': 'Bedrooms',
      'kitchen': 'Kitchen',
      'bathrooms': 'Bathrooms',
      'living_room': 'Living room',
      'other_area': 'Other',

      // ===================== COOKER =====================
      'service_type': 'Service type',
      'meals': 'Meals',
      'meals.*': 'Meal option',
      'cuisine_type': 'Cuisine type',
      'people_count': 'Number of people',
      'guests_count': 'Number of guests',
      'dishes_count': 'Number of dishes',

      // Enums
      'catering': 'Catering',
      'home_cooking': 'Home cooking',
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snacks': 'Snacks',
      'local': 'Local',
      'foreign': 'Foreign',
      'mixed': 'Mixed',

      // ===================== BABYSITTER =====================
      'children_count': 'Children count',
      'children_ages': 'Children ages',
      'children_ages.*': 'Child age',
      'has_medical_or_allergies': 'Has medical conditions or allergies',
      'medical_allergies_details': 'Medical/allergies details',

      // ===================== NURSE =====================
      'patient_age': 'Patient age',
      'medical_conditions': 'Medical conditions',
      'care_needed': 'Care needed',
      'care_needed.*': 'Care option',
      'overnight': 'Overnight care',

      // ===================== TUTOR =====================
      'subjects': 'Subjects',
      'subjects.*': 'Subject',
      'students_count': 'Number of students',
      'education_level': 'Education level',
      'goal': 'Learning goal',

      // Enums
      'primary': 'Primary',
      'secondary': 'Secondary',
      'university': 'University',
      'other_goal': 'Other',
      'homework_help': 'Homework help',
      'exam_prep': 'Exam preparation',
      'skill_improvement': 'Skill improvement',

      // ===================== DRIVER =====================
      'vehicle_provided': 'Vehicle provided',
      'route_destination': 'Route destination',
      'license_category': 'License category',
      'passengers_count': 'Passengers count',
      'ride_mode': 'Ride mode',

      // Enums
      'commute': 'Commute',
      'school_run': 'School run',
      'trip': 'Trip',
      'drop_off': 'Drop off',
      'pickup': 'Pick up',
      'both': 'Both',

      // ===================== GUARD =====================
      'location_type': 'Location type',
      'shift': 'Shift',
      'duration_value': 'Duration value',
      'duration_unit': 'Duration unit',
      'has_security_concerns': 'Has security concerns',
      'security_concerns_details': 'Security concerns details',
      'weapon_required': 'Weapon required',
      'leave_frequency_per_month': 'Leave frequency per month',

      // Enums
      'residence': 'Residence',
      'business': 'Business',
      'event': 'Event',
      'day': 'Day',
      'night': 'Night',
      'twenty_four': '24 Hours',
      'days': 'Days',
      'weeks': 'Weeks',

      // ===================== GARDENER =====================
      'garden_size': 'Garden size',
      'tools_provided': 'Tools provided',

      // ===================== ARASH (Farmer) =====================
      'land_size_sqm': 'Land size (sqm)',
      'crop_type': 'Crop type',

      // ===================== ELECTRICIAN =====================
      'work_type': 'Work type',
      'system': 'System',
      'safety_concerns': 'Safety concerns',
      'safety_concerns_details': 'Safety concerns details',
      'power_on': 'Power on',

      // Enums
      'installation': 'Installation',
      'repair': 'Repair',
      'inspection': 'Inspection',

      // ===================== PLUMBER =====================
      'problem_type': 'Problem type',
      'fixtures': 'Fixtures',
      'fixtures.*': 'Fixture',
      'urgency': 'Urgency',
      'water_on': 'Water on',

      // Enums
      'leak': 'Leak',
      'blockage': 'Blockage',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',

      // ===================== HANDYMAN =====================
      'tools_available': 'Tools available',
      'special_access': 'Special access',

      // ===================== PAINTER =====================
      'painting_type': 'Painting type',
      'interior_or_exterior': 'Interior or exterior',
      'area_size': 'Area size',
      'surface_types': 'Surface types',
      'surface_types.*': 'Surface type',
      'materials_provided': 'Materials provided',

      // Enums
      'new_home': 'New home',
      'renewal': 'Renewal',
      'interior': 'Interior',
      'exterior': 'Exterior',

      // ===================== DISH INSTALLATION =====================
      'installation_location': 'Installation location',
      'ladder_needed': 'Ladder needed',
      'signal_cable_run': 'Signal cable run',
      'wall_drilling_required': 'Wall drilling required',

      // Enums
      'roof': 'Roof',
      'wall': 'Wall',
      'balcony': 'Balcony',

      // ===================== FULL-TIME HOME MAID =====================
      'family_size': 'Family size',
      'accommodation_provided': 'Accommodation provided',
      'live_mode': 'Live mode',
      // 'leave_frequency_per_month': 'Leave frequency per month',

      // Enums
      'live_in': 'Live in',
      'live_out': 'Live out',

      // ===================== PART-TIME HOME MAID =====================
      'hours_per_day': 'Hours per day',
      'frequency': 'Frequency',

      // Enums
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',

      // ===================== SALESPERSON =====================
      'product_service': 'Product/Service',
      'work_location': 'Work location',
      'working_hours': 'Working hours',
      'languages': 'Languages',
      'languages.*': 'Language',
      'compensation_type': 'Compensation type',

      // Enums
      'shop': 'Shop',
      // 'event': 'Event',
      'field': 'Field',
      'online': 'Online',
      'full_time': 'Full time',
      'part_time': 'Part time',
      'amharic': 'Amharic',
      'english': 'English',
      'commission': 'Commission',
      'salary': 'Salary',
      'both_comp': 'Both',

      // ===================== HAIRDRESSER =====================
      'service_types': 'Service types',
      'service_types.*': 'Service type',
      'clients_count': 'Clients count',
      'service_location': 'Service location',

      // Enums
      'home_service': 'Home service',
      'salon': 'Salon',

      // ===================== MAKEUP ARTIST =====================
      'occasion': 'Occasion',
      'products_provided': 'Products provided',

      // Enums
      'wedding': 'Wedding',
      'casual': 'Casual',
      'photoshoot': 'Photoshoot',

      // ===================== NAIL TECHNICIAN =====================
      // (fields already covered: service_types, clients_count, service_location, products_provided)

      // ===================== SPA SERVICES =====================
      // (same fields as nail technician, hairdresser)
    },
    'am': {
      'cert': "ሰርተፍኬቶች",
      'name': "ስም",
      'filters': 'ማጣሪያዎች',
      'favorites': 'የሚወዱት',
      'remove_from_favorites': 'ከየሚወዱት ውስጥ አስወግድ',
      'remove_from_favorites_confirmation':
          '@nameን ከየሚወዱት ውስጥ ማስወገድ እርግጠኛ ነዎት?',
      'no_favorites_found': 'የሚወዱት አልተገኙም',
      'no_favorites_description': 'እስካሁን ምንም አገልግሎት ሰጪዎችን ወደ የሚወዱት አልጨመርክም።',
      'remove': 'አስወግድ',
      'cancel': 'ሰርዝ',
      'my_bookings': 'የእኔ ቦኪንጎች',
      'no_bookings_found': 'ቦኪንጎች አልተገኙም',
      'no_bookings_description': 'እስካሁን ምንም ቦኪንጎች አላደረጉም።',
      'booking_id': 'ቦኪንግ #@id',
      'start_time': 'የመጀመሪያ ጊዜ',
      'end_time': 'የመጨረሻ ጊዜ',
      'provider_id': 'የአገልግሎት ሰጪ ID',
      'category_id': 'የምድብ ID',
      'notes': 'ማስታወሻዎች',
      'booking_details': 'የቦኪንግ ዝርዝሮች',
      'created_at': 'የተፈጠረበት ጊዜ',
      'pending': 'በመጠባበቅ ላይ',
      'confirmed': 'ተረጋግጧል',
      'cancelled': 'ተሰርዟል',
      'completed': 'ተጠናቋል',
      'yes': 'አዎ',
      'no': 'አይ',
      'rating': 'ደረጃ',
      'radius': 'የስራ ራዲየስ',
      'category': 'ምድብ',
      'found': "(@amount) ተገኝቷል",
      "sort_by": 'ደርድር',
      "no_categories_found": "ምንም ምድቦች አልተገኙም",
      "no_providers_found": "ምንም አገልግሎት ሰጪዎች አልተገኙም",
      "top_rated": "ከፍተኛ ደረጃ",
      "professional": "ባለሙያዎች",
      "nearby": "በአቅራቢያዎ",
      "search": "አገልግሎት ሰጪዎችን ይፈልጉ...",
      'email_phone': 'ኢሜል/ስልክ ቁጥር',
      'step_personal_info': 'የግል መረጃ',
      'step_contact_details': 'ስልክ',
      'step_address_info': 'የአድራሻ መረጃ',
      'step_profile_picture': 'የፕሮፋይል ፎቶ',
      'name_required': 'ስም ያስፈልጋል',
      'phone_required': 'ስልክ ቁጥር ያስፈልጋል',
      'loading_city': 'ከተሞችን በመጫን ላይ...',
      'loading_sub_city': 'ክፍለ ከተሞችን በመጫን ላይ...',
      'load_failed_retry': 'አልተሳካም። ዳግሜ ለመሞከር ይጫኑ',
      'woreda_required': 'ወረዳ ያስፈልጋል',
      'house_number_required': 'የቤት ቁጥር ያስፈልጋል',
      'pick_profile_picture': 'የፕሮፋይል ፎቶ ይምረጡ',
      'previous': 'ወደ ኋላ',
      'next': 'ወደ ፊት',
      'login': 'ግባ',
      'valid_email': 'ትክክለኛ ኢሜል አስገባ።',
      'email': 'ኢሜል',
      'must_include_up_to_grand_father': 'ስም እስከ አያት ድረስ ማካተት አለበት',
      'city': 'ከተማ',
      'sub_city': 'ክፍለ ከተማ',
      'woreda': 'ወረዳ',
      'house_number': 'የቤት ቁጥር',
      'secondary_phone': 'አማራጭ ስልክ',
      'landline_phone': 'የመስመር ስልክ',
      'password': 'የይለፍ ቃል',
      'password_requirement': 'የይለፍ ቃሉ ቢያንስ 8 ፊደል መሆን አለበት።',
      'confirm_pass': 'የይለፍ ቃል ያረጋግጡ',
      'pass_not_match': "የይለፍ ቃሎቹ አይመሳሰሉም",
      'password_must_have_one_uppercase': 'የይለፍ ቃሉ ቢያንስ አንድ ካፒታል ፊደል ሊኖረዉ ይገባል',
      'password_must_have_one_lowercase':
          'የይለፍ ቃሉ ቢያንስ አንድ ካፒታል ያልሆነ ፊደል ሊኖረዉ ይገባል',
      'password_must_have_one_number': 'የይለፍ ቃሉ ቢያንስ አንድ ቁጥር ሊኖረዉ ይገባል',
      'password_must_have_one_special_character':
          'የይለፍ ቃሉ ቢያንስ አንድ ልዩ ፊደል ሊኖረዉ ይገባል',
      'create_account': 'መለያ ፍጠር',
      'first_name_requirement': 'የመጀመሪያ ስም ቢያንስ 2 ፊደል መሆን አለበት።',
      'full_name': 'ስም (እስከ ሃያት)',
      'last_name_requirement': 'የመጨረሻ ስም ቢያንስ 2 ፊደል መሆን አለበት።',
      'last_name': 'የመጨረሻ ስም',
      'phone_number': 'ስልክ ቁጥር',
      'invalid_phone': 'የተሳሳተ ስልክ ቁጥር',
      'no_trips_yet': 'ጉዞ የለም',
      'no_trips_description': 'እስካሁን ምንም ጉዞ አልወሰድህም። እንጀምር!',
      'no_routes_yet': 'የተመዘገቡ መንገዶች የሉም',
      'no_routes_found': 'ሰርቨር ላይ የተመዘገበ መንገድ አልተገኘም። እባክዎ ቆይተዉ በድጋሜ ይሞክሩ።',
      'refresh': 'በድጋሜ ይሞክሩ',
      'subscribe_route': 'በዚህ መንገድ ላይ ይመዝገቡ',
      'unnamed_stop': 'ያልተሰየመ መደብ',
      'km_from_previous': 'ኪ.ሜ ከቀደመው ',
      'my_wallet': 'የእኔ ዋሌት',
      'help_support': 'እርዳታ እና ድጋፍ',
      'about_us': 'ስለ እኛ',
      'terms_conditions': 'ውሎች እና መመሪያዎች',
      'privacy_policy': 'የግላዊነት ፖሊሲ',
      'logout': 'ውጣ',
      'no_account': 'መለያ የለዎትም? ',
      'have_account': 'አካውንት አለዎት? ',
      'sign_up_here': 'እዚህ ይመዝገቡ',
      'log_in_here': 'እዚህ ይግቡ',
      'no_internet': 'ኢንተርኔት አልተገኘም',
      'no_internet_description': 'ኢንተርኔትዎ ተጠፍቷል። እባክዎ ያብሩና ደግመው ይሞክሩ።',
      'retry': 'በድጋሜ ይሞክሩ',
      'check_connection': 'እባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ እና ደግመው ይሞክሩ።',
      'internal_server_error': 'የሰርቨር ስህተት',
      'internal_server_error_desc': 'ሰርቨሩ ላይ ስህተት ተፈጥሯል እና ጥያቄዎን ማጠናቀቅ አልቻለም።',
      'service_unavailable': 'አገልግሎቱ አይገኝም',
      'service_unavailable_desc':
          'አገልግሎቱ ለጊዜዉ እየተሰጠ አይደለም። እባክዎ በኋላ ደግመው ይሞክሩ።',
      'not_found': 'አልተገኘም',
      'not_found_desc': 'የተጠየቀው መረጃ በሰርቨሩ ላይ አልተገኘም።',
      'gateway_timeout': 'የተሰጠዎት ጊዜ አልቋል',
      'gateway_timeout_desc': 'ሰርቨሩ የተገባ ምላሽ በጊዜ አልሰጠም።',
      'unauthorized': 'ፈቃድ የለዎትም',
      'unauthorized_desc': 'ይህን መረጃ ለማግኘት ፈቃድ የለዎትም።',
      'forbidden': 'አይችሉም',
      'forbidden_desc': 'ይህን መረጃ ማግኘት ክልክል ነዉ።',
      'too_many_requests': 'ብዙ ጥያቄዎች',
      'too_many_requests_desc': 'በትንሽ ጊዜ ውስጥ ብዙ ጥያቄዎች ልከዋል።',
      'error': 'ስህተት',
      'unknown_error': 'ያልታወቀ ስህተት',
      'unexpected_error': 'ያልተጠበቀ ስህተት ተፈጥሯል፣ እባክዎ በኋላ ይሞክሩ',

      // ===================== COMMON FIELDS =====================
      'size': 'መጠን',
      'areas': 'ቦታዎች',
      'areas.*': 'የቦታ አማራጭ',
      'tasks': 'ተግባሮች',
      'tasks.*': 'ተግባር',
      'photos': 'ፎቶዎች',
      'photos.*': 'ፎቶ',

      // ===================== CLEANER =====================
      'type_of_space': 'ቦታው አይነት',
      'supplies_available': 'አቅርቦት አለ',
      'pets_present': 'እንስሶች አሉ',

      // Enums
      'home': 'ቤት',
      'office': 'ቢሮ',
      'apartment': 'አፓርታማ',
      'other': 'ሌላ',
      'bedrooms': 'መኝታ ክፍሎች',
      'kitchen': 'ኩዊን',
      'bathrooms': 'መታጠቢያ ቤቶች',
      'living_room': 'መኖሪያ ክፍል',
      'other_area': 'ሌላ',

      // ===================== COOKER =====================
      'service_type': 'የአገልግሎት አይነት',
      'meals': 'ምግቦች',
      'meals.*': 'የምግብ አማራጭ',
      'cuisine_type': 'የምግብ አይነት',
      'people_count': 'የሰዎች ብዛት',
      'guests_count': 'የእንግዶች ብዛት',
      'dishes_count': 'የምግብ ዕቃዎች ብዛት',

      // Enums
      'catering': 'የምግብ አገልግሎት',
      'home_cooking': 'ቤት ምግብ',
      'breakfast': 'ቁርስ',
      'lunch': 'ቀን ምሳ',
      'dinner': 'እራት',
      'snacks': 'ነገር ቀላል',
      'local': 'አካባቢያዊ',
      'foreign': 'የውጭ',
      'mixed': 'ተቀላቀለ',

      // ===================== BABYSITTER =====================
      'children_count': 'የልጆች ብዛት',
      'children_ages': 'የልጆች ዕድሜ',
      'children_ages.*': 'የልጅ ዕድሜ',
      'has_medical_or_allergies': 'ሕክምና ችግር ወይም አለርጂ አለው',
      'medical_allergies_details': 'የሕክምና/አለርጂ ዝርዝሮች',

      // ===================== NURSE =====================
      'patient_age': 'የታካሚ ዕድሜ',
      'medical_conditions': 'የሕክምና ሁኔታዎች',
      'care_needed': 'የሚያስፈልገው እንክብካቤ',
      'care_needed.*': 'የእንክብካቤ አማራጭ',
      'overnight': 'በሌሊት እንክብካቤ',

      // ===================== TUTOR =====================
      'subjects': 'ትምህርቶች',
      'subjects.*': 'ትምህርት',
      'students_count': 'የተማሪዎች ብዛት',
      'education_level': 'የትምህርት ደረጃ',
      'goal': 'የትምህርት ግብ',

      // Enums
      'primary': 'ቀዳሚ',
      'secondary': 'ሁለተኛ',
      'university': 'ዩኒቨርሲቲ',
      'other_goal': 'ሌላ',
      'homework_help': 'የቤት ስራ እርዳታ',
      'exam_prep': 'የፈተና አዘጋጅት',
      'skill_improvement': 'ችሎታ ማሻሻያ',

      // ===================== DRIVER =====================
      'vehicle_provided': 'መኪና አለ',
      'route_destination': 'የመንገድ መድረሻ',
      'license_category': 'የፈቃድ ምድብ',
      'passengers_count': 'የተሳፋሪዎች ብዛት',
      'ride_mode': 'የጉዞ አይነት',

      // Enums
      'commute': 'የተለመደ ጉዞ',
      'school_run': 'የትምህርት ቤት መዞር',
      'trip': 'ጉዞ',
      'drop_off': 'መውረድ',
      'pickup': 'መውሰድ',
      'both': 'ሁለቱም',

      // ===================== GUARD =====================
      'location_type': 'የቦታ አይነት',
      'shift': 'ጊዜ',
      'duration_value': 'የጊዜ ቆይታ',
      'duration_unit': 'የጊዜ መለኪያ',
      'has_security_concerns': 'የደህንነት ችግር አለ',
      'security_concerns_details': 'የደህንነት ችግር ዝርዝሮች',
      'weapon_required': 'መሣሪያ ያስፈልጋል',
      'leave_frequency_per_month': 'በወር የእረፍት ጊዜ ብዛት',

      // Enums
      'residence': 'መኖሪያ',
      'business': 'ንግድ',
      'event': 'ዝግጅት',
      'day': 'ቀን',
      'night': 'ሌሊት',
      'twenty_four': '24 ሰዓት',
      'days': 'ቀናት',
      'weeks': 'ሳምንታት',

      // ===================== GARDENER =====================
      'garden_size': 'የአትክልት መጠን',
      'tools_provided': 'መሳሪያ አለ',

      // ===================== ARASH (Farmer) =====================
      'land_size_sqm': 'የመሬት መጠን (ካሬ ሜትር)',
      'crop_type': 'የእህል አይነት',

      // ===================== ELECTRICIAN =====================
      'work_type': 'የሥራ አይነት',
      'system': 'ስርዓት',
      'safety_concerns': 'የደህንነት ችግር',
      'safety_concerns_details': 'የደህንነት ችግር ዝርዝሮች',
      'power_on': 'ኃይል ተነስቷል',

      // Enums
      'installation': 'ጭነት',
      'repair': 'ጥገና',
      'inspection': 'እይታ',

      // ===================== PLUMBER =====================
      'problem_type': 'የችግር አይነት',
      'fixtures': 'መቀመጫዎች',
      'fixtures.*': 'መቀመጫ',
      'urgency': 'አስቸኳይነት',
      'water_on': 'ውሃ አለ',

      // Enums
      'leak': 'ፍሳሽ',
      'blockage': 'መዘጋት',
      'low': 'ዝቅተኛ',
      'medium': 'መካከለኛ',
      'high': 'ከፍተኛ',

      // ===================== HANDYMAN =====================
      'tools_available': 'መሳሪያ አለ',
      'special_access': 'ልዩ መዳረሻ',

      // ===================== PAINTER =====================
      'painting_type': 'የመስተካከል አይነት',
      'interior_or_exterior': 'ውስጥ ወይም ውጪ',
      'area_size': 'የቦታ መጠን',
      'surface_types': 'የፊት አይነቶች',
      'surface_types.*': 'የፊት አይነት',
      'materials_provided': 'ቁሳቁስ አለ',

      // Enums
      'new_home': 'አዲስ ቤት',
      'renewal': 'እንደገና መቀየር',
      'interior': 'ውስጥ',
      'exterior': 'ውጪ',

      // ===================== DISH INSTALLATION =====================
      'installation_location': 'የመጫን ቦታ',
      'ladder_needed': 'መሰረዣ ያስፈልጋል',
      'signal_cable_run': 'ሲግናል ገመድ ይዘርጋል',
      'wall_drilling_required': 'ቅጥር መቆረጥ ያስፈልጋል',

      // Enums
      'roof': 'ሰሌዳ',
      'wall': 'ቅጥር',
      'balcony': 'ባልኮኒ',

      // ===================== FULL-TIME HOME MAID =====================
      'family_size': 'የቤተሰብ መጠን',
      'accommodation_provided': 'መኖሪያ ተሰጥቷል',
      'live_mode': 'የመኖር ሁኔታ',
      // 'leave_frequency_per_month': 'በወር የሚሰጠው እረፍት',

      // Enums
      'live_in': 'በቤት ውስጥ',
      'live_out': 'በቤት ውጭ',

      // ===================== PART-TIME HOME MAID =====================
      'hours_per_day': 'በቀን ሰዓቶች',
      'frequency': 'ድግግሞሽ',

      // Enums
      'daily': 'በየቀኑ',
      'weekly': 'በየሳምንቱ',
      'monthly': 'በየወሩ',

      // ===================== SALESPERSON =====================
      'product_service': 'ምርት/አገልግሎት',
      'work_location': 'የስራ ቦታ',
      'working_hours': 'የስራ ሰዓት',
      'languages': 'ቋንቋዎች',
      'languages.*': 'ቋንቋ',
      'compensation_type': 'የክፍያ አይነት',

      // Enums
      'shop': 'መደብር',
      // 'event': 'ዝግጅት',
      'field': 'መሬት ላይ',
      'online': 'መስመር ላይ',
      'full_time': 'ሙሉ ቀን',
      'part_time': 'ከፊል ቀን',
      'amharic': 'አማርኛ',
      'english': 'እንግሊዝኛ',
      'commission': 'ኮሚሽን',
      'salary': 'ደመወዝ',
      'both_comp': 'ሁለቱም',

      // ===================== HAIRDRESSER =====================
      'service_types': 'የአገልግሎት አይነቶች',
      'service_types.*': 'የአገልግሎት አይነት',
      'clients_count': 'የደንበኞች ብዛት',
      'service_location': 'የአገልግሎት ቦታ',

      // Enums
      'home_service': 'በቤት ውስጥ',
      'salon': 'ሳሎን',

      // ===================== MAKEUP ARTIST =====================
      'occasion': 'ግብዣ/ዝግጅት',
      'products_provided': 'ምርቶች ተሰጥተዋል',

      // Enums
      'wedding': 'ሰርግ',
      'casual': 'መደበኛ',
      'photoshoot': 'ፎቶ ስትዮ',

      // ===================== NAIL TECHNICIAN =====================
      // (fields already covered)

      // ===================== SPA SERVICES =====================
      // (same fields as hairdresser, nail technician)
    },
  };
}
