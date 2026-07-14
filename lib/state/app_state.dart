import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String category;
  final String condition;
  final String description;
  final double rating;
  final int reviewsCount;
  final String sellerName;
  bool isFavorite;
  bool isSold;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.condition,
    required this.description,
    required this.sellerName,
    this.rating = 4.5,
    this.reviewsCount = 12,
    this.isFavorite = false,
    this.isSold = false,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class ChatMessage {
  final String message;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.message,
    required this.time,
    required this.isMe,
  });
}

class ChatConversation {
  final String id;
  final String userName;
  String lastMessage;
  String lastMessageTime;
  int unreadCount;
  final String? productImageUrl;
  final String productTitle;
  final ValueNotifier<List<ChatMessage>> messagesNotifier;

  ChatConversation({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.productImageUrl,
    required this.productTitle,
    required List<ChatMessage> initialMessages,
  }) : messagesNotifier = ValueNotifier<List<ChatMessage>>(initialMessages);
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type; // "Messages" or "Sales" or "System"

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });
}

class AppState {
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);

  static Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      darkModeNotifier.value = prefs.getBool('darkMode') ?? false;
    } catch (e) {
      debugPrint("Error loading dark mode preference: $e");
    }
  }

  static Future<void> toggleDarkMode(bool enabled) async {
    try {
      darkModeNotifier.value = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', enabled);
    } catch (e) {
      debugPrint("Error saving dark mode preference: $e");
    }
  }

  // Session details
  static final ValueNotifier<String> userRoleNotifier = ValueNotifier<String>("Buyer");
  static final ValueNotifier<String> nameNotifier = ValueNotifier<String>("Rehan Khan");
  static final ValueNotifier<String> emailNotifier = ValueNotifier<String>("rehan.khan@example.com");
  static final ValueNotifier<String> phoneNotifier = ValueNotifier<String>("+92 300 1234567");

  // Dynamic Lists
  static final ValueNotifier<List<Product>> productsNotifier = ValueNotifier<List<Product>>([
    Product(
      id: "1",
      title: "Calculus Textbook",
      price: 25.00,
      imageUrl: "assets/images/calculus_textbook.jpg",
      category: "Books",
      condition: "Good",
      description: "Standard university Calculus textbook. Excellent condition, cover has minor wear but all pages are unmarked and clean.",
      sellerName: "StudyHub Co.",
      rating: 4.8,
      reviewsCount: 24,
    ),
    Product(
      id: "2",
      title: "Physics Notes",
      price: 10.00,
      imageUrl: "assets/images/physics_notes.jpg",
      category: "Notes",
      condition: "Like New",
      description: "Detailed hand-written notes for College Physics. Covering Classical Mechanics, Electromagnetism, and Optics. Diagrams included.",
      sellerName: "Sarah J.",
      rating: 4.7,
      reviewsCount: 8,
    ),
    Product(
      id: "3",
      title: "Scientific Calculator",
      price: 15.00,
      imageUrl: "assets/images/scientific_calculator.jpg",
      category: "Electronics",
      condition: "Good",
      description: "Texas Instruments scientific calculator, perfect for high school or college math and science classes. Battery included and working.",
      sellerName: "Alex Mercer",
      rating: 4.5,
      reviewsCount: 15,
    ),
    Product(
      id: "4",
      title: "Engineering Mathematics",
      price: 30.00,
      imageUrl: "assets/images/engineering_math.jpg",
      category: "Books",
      condition: "Good",
      description: "Very good condition. Useful for first year engineering students. Contains solved examples and practice questions.",
      sellerName: "StudyHub Co.",
      rating: 4.8,
      reviewsCount: 24,
    ),
    Product(
      id: "5",
      title: "Chemistry Notes",
      price: 12.00,
      imageUrl: "assets/images/chemistry_notes.jpg",
      category: "Notes",
      condition: "Fair",
      description: "Complete organic chemistry notes. Highlights on important reactions and mechanism flows.",
      sellerName: "Zainab B.",
      rating: 4.2,
      reviewsCount: 6,
    ),
    Product(
      id: "6",
      title: "Biology Textbook",
      price: 28.00,
      imageUrl: "assets/images/biology_textbook.jpg",
      category: "Books",
      condition: "Like New",
      description: "Essential Biology for modern science majors. Barely used with code online access valid.",
      sellerName: "Professor John",
      rating: 4.9,
      reviewsCount: 19,
    ),
    Product(
      id: "7",
      title: "OS Notes",
      price: 8.00,
      imageUrl: "assets/images/os_notes.jpg",
      category: "Notes",
      condition: "Like New",
      description: "Syllabus-aligned Operating System notes, compiling exam questions and summaries for quick reference.",
      sellerName: "Amna R.",
      rating: 4.6,
      reviewsCount: 11,
    ),
    Product(
      id: "8",
      title: "Graphing Calculator",
      price: 18.00,
      imageUrl: "assets/images/graphing_calculator.jpg",
      category: "Electronics",
      condition: "Good",
      description: "Fully featured graphing calculator model, ideal for engineering mathematics tasks. Screen is scratch-free.",
      sellerName: "Daniyal K.",
      rating: 4.4,
      reviewsCount: 14,
    ),
    Product(
      id: "9",
      title: "Lab Coat",
      price: 15.00,
      imageUrl: "assets/images/lab_coat.jpg",
      category: "Others",
      condition: "Good",
      description: "White lab coat, medium size. Made from durable cotton blend. Gently used in biology classes, washed and clean.",
      sellerName: "Nafisa S.",
      rating: 4.7,
      reviewsCount: 3,
    ),
    Product(
      id: "10",
      title: "Lab Notebook",
      price: 6.00,
      imageUrl: "assets/images/lab_notebook.jpg",
      category: "Stationery",
      condition: "New",
      description: "Standard carbonless copy notebook for chemistry labs. Grid layout, clean sheets.",
      sellerName: "Stationery Mart",
      rating: 5.0,
      reviewsCount: 1,
    ),
    Product(
      id: "11",
      title: "Programming Book",
      price: 22.00,
      imageUrl: "assets/images/programming_book.jpg",
      category: "Books",
      condition: "Good",
      description: "Introduction to Programming in Python. Covers basics to advanced topics with exercises.",
      sellerName: "CodeMaster",
      rating: 4.6,
      reviewsCount: 30,
    ),
    Product(
      id: "12",
      title: "DBMS Notes",
      price: 9.00,
      imageUrl: "assets/images/dbms_notes.jpg",
      category: "Notes",
      condition: "Like New",
      description: "Complete Database Management System notes. Includes ER diagrams, normalization, and SQL queries.",
      sellerName: "Huma A.",
      rating: 4.5,
      reviewsCount: 9,
    ),
    Product(
      id: "13",
      title: "Laptop Stand",
      price: 12.00,
      imageUrl: "assets/images/laptop_stand.jpg",
      category: "Electronics",
      condition: "Like New",
      description: "Adjustable aluminum laptop stand. Lightweight and portable, ideal for campus use.",
      sellerName: "TechDeals",
      rating: 4.3,
      reviewsCount: 7,
    ),
    Product(
      id: "14",
      title: "USB Keyboard",
      price: 14.00,
      imageUrl: "assets/images/usb_keyboard.jpg",
      category: "Electronics",
      condition: "Good",
      description: "Compact wired USB keyboard. All keys fully functional, great for students.",
      sellerName: "Bilal R.",
      rating: 4.0,
      reviewsCount: 5,
    ),
    Product(
      id: "15",
      title: "Geometry Box",
      price: 4.00,
      imageUrl: "assets/images/geometry_box.jpg",
      category: "Stationery",
      condition: "New",
      description: "Complete geometry box with compass, ruler, protractor and set squares.",
      sellerName: "Stationery Hub",
      rating: 4.8,
      reviewsCount: 20,
    ),
    Product(
      id: "16",
      title: "Marker Set",
      price: 5.00,
      imageUrl: "assets/images/marker_set.jpg",
      category: "Stationery",
      condition: "New",
      description: "Pack of 12 assorted color markers. Great for assignments, notes, and posters.",
      sellerName: "Color World",
      rating: 4.7,
      reviewsCount: 14,
    ),
    Product(
      id: "17",
      title: "USB Drive 32GB",
      price: 8.00,
      imageUrl: "assets/images/usb_drive.jpg",
      category: "Others",
      condition: "Like New",
      description: "32GB USB flash drive. Fast read/write speed. Ideal for storing lecture slides and projects.",
      sellerName: "TechMart",
      rating: 4.4,
      reviewsCount: 8,
    ),
    Product(
      id: "18",
      title: "Drawing Board",
      price: 10.00,
      imageUrl: "assets/images/drawing_board.jpg",
      category: "Others",
      condition: "Good",
      description: "A3 size drawing board for engineering and arts students. Smooth surface, clean edges.",
      sellerName: "ArtStore",
      rating: 4.5,
      reviewsCount: 6,
    ),
    Product(
      id: "19",
      title: "Headphones",
      price: 20.00,
      imageUrl: "assets/images/headphones.jpg",
      category: "Electronics",
      condition: "Good",
      description: "Over-ear wired headphones, perfect for studying with noise isolation. Clear audio quality.",
      sellerName: "SoundHub",
      rating: 4.3,
      reviewsCount: 12,
    ),
    Product(
      id: "20",
      title: "Sticky Notes Pack",
      price: 3.00,
      imageUrl: "assets/images/sticky_notes.jpg",
      category: "Stationery",
      condition: "New",
      description: "Bright color 5-pack sticky notes. 100 sheets each, perfect for class notes and reminders.",
      sellerName: "Stationery Mart",
      rating: 4.9,
      reviewsCount: 22,
    ),
  ]);

  static final ValueNotifier<List<CartItem>> cartNotifier = ValueNotifier<List<CartItem>>([]);
  
  static final ValueNotifier<List<Product>> wishlistNotifier = ValueNotifier<List<Product>>([]);

  static final ValueNotifier<List<ChatConversation>> conversationsNotifier = ValueNotifier<List<ChatConversation>>([
    ChatConversation(
      id: "c1",
      userName: "Ali Ahmed",
      lastMessage: "Is the Calculus textbook still available?",
      lastMessageTime: "5 min ago",
      unreadCount: 1,
      productTitle: "Calculus Textbook",
      productImageUrl: "assets/images/book_cover.jpg",
      initialMessages: [
        ChatMessage(message: "Hello! Interested in the Calculus textbook.", time: "1 hour ago", isMe: false),
        ChatMessage(message: "Yes it is! I can hand it over on campus tomorrow.", time: "30 min ago", isMe: true),
        ChatMessage(message: "Is the Calculus textbook still available?", time: "5 min ago", isMe: false),
      ],
    ),
    ChatConversation(
      id: "c2",
      userName: "Sarah Jenkins",
      lastMessage: "I uploaded the chemistry lab slides for you.",
      lastMessageTime: "2 hours ago",
      unreadCount: 0,
      productTitle: "Chemistry Slides",
      productImageUrl: "assets/images/written_notes.jpg",
      initialMessages: [
        ChatMessage(message: "Can you send the slides?", time: "3 hours ago", isMe: true),
        ChatMessage(message: "I uploaded the chemistry lab slides for you.", time: "2 hours ago", isMe: false),
      ],
    ),
  ]);

  static final ValueNotifier<List<AppNotification>> notificationsNotifier = ValueNotifier<List<AppNotification>>([
    AppNotification(
      id: "n1",
      title: "Order Placed Successfully",
      body: "Your order for Physics Notes has been received.",
      time: "15 min ago",
      type: "System",
    ),
    AppNotification(
      id: "n2",
      title: "New Message Received",
      body: "Ali Ahmed sent you a message about the textbook.",
      time: "1 hour ago",
      type: "Messages",
    ),
    AppNotification(
      id: "n3",
      title: "Listing Published",
      body: "Your listing for Scientific Calculator is now live.",
      time: "1 day ago",
      type: "Sales",
    ),
  ]);

  // Orders lists
  static final ValueNotifier<List<Product>> buyerOrdersNotifier = ValueNotifier<List<Product>>([]);
  
  static final ValueNotifier<List<Product>> sellerReceivedOrdersNotifier = ValueNotifier<List<Product>>([
    Product(
      id: "101",
      title: "Engineering Mathematics",
      price: 30.00,
      imageUrl: "assets/images/engineering_math.jpg",
      category: "Books",
      condition: "Good",
      description: "",
      sellerName: "StudyHub Co.",
      isSold: true,
    ),
  ]);

  // Methods to manipulate state
  static void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    if (product.isFavorite) {
      if (!wishlistNotifier.value.any((p) => p.id == product.id)) {
        wishlistNotifier.value = [...wishlistNotifier.value, product];
      }
    } else {
      wishlistNotifier.value = wishlistNotifier.value.where((p) => p.id != product.id).toList();
    }
    // trigger rebuild of observers
    productsNotifier.value = [...productsNotifier.value];
  }

  static void addToCart(Product product) {
    final existingIndex = cartNotifier.value.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      cartNotifier.value[existingIndex].quantity += 1;
      cartNotifier.value = [...cartNotifier.value];
    } else {
      cartNotifier.value = [...cartNotifier.value, CartItem(product: product)];
    }
  }

  static void removeFromCart(Product product) {
    cartNotifier.value = cartNotifier.value.where((item) => item.product.id != product.id).toList();
  }

  static void incrementCartItem(Product product) {
    final idx = cartNotifier.value.indexWhere((item) => item.product.id == product.id);
    if (idx >= 0) {
      cartNotifier.value[idx].quantity += 1;
      cartNotifier.value = [...cartNotifier.value];
    }
  }

  static void decrementCartItem(Product product) {
    final idx = cartNotifier.value.indexWhere((item) => item.product.id == product.id);
    if (idx >= 0) {
      if (cartNotifier.value[idx].quantity > 1) {
        cartNotifier.value[idx].quantity -= 1;
        cartNotifier.value = [...cartNotifier.value];
      } else {
        removeFromCart(product);
      }
    }
  }

  static void checkout() {
    // Add cart items to buyer orders
    final List<Product> checkedOut = cartNotifier.value.map((item) => item.product).toList();
    buyerOrdersNotifier.value = [...buyerOrdersNotifier.value, ...checkedOut];
    cartNotifier.value = [];
    
    // add notification
    notificationsNotifier.value = [
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Checkout Complete",
        body: "Your checkout was successful! Items are pending delivery.",
        time: "Just now",
        type: "System",
      ),
      ...notificationsNotifier.value
    ];
  }

  static void addProduct(Product product) {
    productsNotifier.value = [product, ...productsNotifier.value];
    // Add notification
    notificationsNotifier.value = [
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Product Published",
        body: "Your listing for '${product.title}' is now live.",
        time: "Just now",
        type: "Sales",
      ),
      ...notificationsNotifier.value
    ];
  }

  static void editProduct(Product product) {
    productsNotifier.value = productsNotifier.value.map((p) {
      if (p.id == product.id) {
        return product;
      }
      return p;
    }).toList();
  }

  static void deleteProduct(String id) {
    productsNotifier.value = productsNotifier.value.where((p) => p.id != id).toList();
  }

  static void markItemSold(String id) {
    productsNotifier.value = productsNotifier.value.map((p) {
      if (p.id == id) {
        p.isSold = true;
      }
      return p;
    }).toList();
  }

  static void addMessage(String convId, String text, {bool isMe = true}) {
    conversationsNotifier.value = conversationsNotifier.value.map((conv) {
      if (conv.id == convId) {
        final messages = [
          ...conv.messagesNotifier.value,
          ChatMessage(message: text, time: "Just now", isMe: isMe)
        ];
        conv.lastMessage = text;
        conv.lastMessageTime = "Just now";
        conv.messagesNotifier.value = messages;
      }
      return conv;
    }).toList();
  }

  static void addNotification(String title, String body, {String type = "System"}) {
    notificationsNotifier.value = [
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        time: "Just now",
        type: type,
      ),
      ...notificationsNotifier.value
    ];
  }

  static void removeNotification(String id) {
    notificationsNotifier.value = notificationsNotifier.value.where((n) => n.id != id).toList();
  }

  static void clearAllNotifications() {
    notificationsNotifier.value = [];
  }
}
