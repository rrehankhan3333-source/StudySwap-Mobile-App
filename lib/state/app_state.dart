import 'dart:async';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final String? sellerId;
  final DateTime? createdAt;
  bool isFavorite;
  bool isSold;
  final int stock;
  final String status;

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
    this.sellerId,
    this.createdAt,
    this.stock = 10,
    this.status = 'active',
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      condition: data['condition'] ?? '',
      description: data['description'] ?? '',
      sellerName: data['sellerName'] ?? 'Unknown Seller',
      rating: (data['rating'] ?? 4.5).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 12,
      isFavorite: false, // Updated reactive to wishlist
      isSold: data['isSold'] ?? false,
      sellerId: data['sellerId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      stock: data['stock'] ?? 10,
      status: data['status'] ?? (data['isSold'] == true || (data['stock'] ?? 10) == 0 ? 'inactive' : 'active'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'condition': condition,
      'description': description,
      'sellerName': sellerName,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isSold': isSold,
      'sellerId': sellerId ?? '',
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'stock': stock,
      'status': status,
    };
  }
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
  final String senderId;
  final DateTime? timestamp;

  ChatMessage({
    required this.message,
    required this.time,
    required this.isMe,
    required this.senderId,
    this.timestamp,
  });

  factory ChatMessage.fromFirestore(
    Map<String, dynamic> data,
    String currentUserId,
  ) {
    final senderId = data['senderId'] ?? '';
    final timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    final hr = timestamp.hour > 12
        ? timestamp.hour - 12
        : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final min = timestamp.minute.toString().padLeft(2, '0');
    final ampm = timestamp.hour >= 12 ? 'PM' : 'AM';
    final timeStr = "$hr:$min $ampm";

    return ChatMessage(
      message: data['text'] ?? data['message'] ?? '',
      time: timeStr,
      isMe: senderId == currentUserId,
      senderId: senderId,
      timestamp: timestamp,
    );
  }
}

class ChatConversation {
  final String id;
  final String userName;
  String lastMessage;
  String lastMessageTime;
  int unreadCount;
  final String? productImageUrl;
  final String productTitle;
  final String buyerId;
  final String sellerId;
  final String productId;
  final ValueNotifier<List<ChatMessage>> messagesNotifier;

  ChatConversation({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.productImageUrl,
    required this.productTitle,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required List<ChatMessage> initialMessages,
  }) : messagesNotifier = ValueNotifier<List<ChatMessage>>(initialMessages);
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type; // "Messages" or "Sales" or "System"
  final String? relatedId;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.relatedId,
    required this.isRead,
  });

  factory AppNotification.fromFirestore(Map<String, dynamic> data, String id) {
    final t = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    // format to "Just now", "5 min ago", "1 day ago" etc.
    final diff = DateTime.now().difference(t);
    String timeStr = "Just now";
    if (diff.inDays > 0) {
      timeStr = "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
    } else if (diff.inHours > 0) {
      timeStr = "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
    } else if (diff.inMinutes > 0) {
      timeStr = "${diff.inMinutes} min ago";
    }

    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      time: timeStr,
      type: data['type'] ?? 'System',
      relatedId: data['relatedId'],
      isRead: data['isRead'] ?? false,
    );
  }
}

class OrderModel {
  final String id;
  final String orderId;
  final String pTitle;
  final double pPrice;
  final String date;
  final String status;
  final String image;
  final String customer;
  final String buyerId;
  final String sellerId;
  final String productId;
  final int quantity;
  final double price;
  final DateTime? createdAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.pTitle,
    required this.pPrice,
    required this.date,
    required this.status,
    required this.image,
    required this.customer,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.createdAt,
    this.completedAt,
  });
}

class AppState {
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(
    false,
  );

  // Auth Instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  // Listeners Subscriptions
  static StreamSubscription? _userSubscription;
  static StreamSubscription? _productsSubscription;
  static StreamSubscription? _cartSubscription;
  static StreamSubscription? _wishlistSubscription;
  static StreamSubscription? _conversationsSubscription;
  static StreamSubscription? _buyerOrdersSubscription;
  static StreamSubscription? _sellerOrdersSubscription;
  static StreamSubscription? _notificationsSubscription;
  static StreamSubscription? _activeMessagesSubscription;

  // Session details
  static final ValueNotifier<String> userRoleNotifier = ValueNotifier<String>(
    "Buyer",
  );
  static final ValueNotifier<String> nameNotifier = ValueNotifier<String>(
    "Loading...",
  );
  static final ValueNotifier<String> emailNotifier = ValueNotifier<String>("");
  static final ValueNotifier<String> phoneNotifier = ValueNotifier<String>("");
  static final ValueNotifier<String> profileImageNotifier =
      ValueNotifier<String>("");

  // Dynamic Lists
  static final ValueNotifier<List<Product>> productsNotifier =
      ValueNotifier<List<Product>>([]);
  static final ValueNotifier<List<CartItem>> cartNotifier =
      ValueNotifier<List<CartItem>>([]);
  static final ValueNotifier<List<Product>> wishlistNotifier =
      ValueNotifier<List<Product>>([]);
  static final ValueNotifier<List<ChatConversation>> conversationsNotifier =
      ValueNotifier<List<ChatConversation>>([]);
  static final ValueNotifier<List<AppNotification>> notificationsNotifier =
      ValueNotifier<List<AppNotification>>([]);

  // Orders lists
  static final ValueNotifier<List<OrderModel>> buyerOrdersNotifier =
      ValueNotifier<List<OrderModel>>([]);
  static final ValueNotifier<List<OrderModel>> sellerReceivedOrdersNotifier =
      ValueNotifier<List<OrderModel>>([]);

  // Global Auth Init Hook
  static void init() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearAllSubscriptions();
      } else {
        _setupAllSubscriptions(user.uid);
      }
    });
  }

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

  static void _clearAllSubscriptions() {
    _userSubscription?.cancel();
    _productsSubscription?.cancel();
    _cartSubscription?.cancel();
    _wishlistSubscription?.cancel();
    _conversationsSubscription?.cancel();
    _buyerOrdersSubscription?.cancel();
    _sellerOrdersSubscription?.cancel();
    _notificationsSubscription?.cancel();
    _activeMessagesSubscription?.cancel();

    nameNotifier.value = "Guest";
    emailNotifier.value = "";
    phoneNotifier.value = "";
    profileImageNotifier.value = "";
    userRoleNotifier.value = "Buyer";

    productsNotifier.value = [];
    cartNotifier.value = [];
    wishlistNotifier.value = [];
    conversationsNotifier.value = [];
    notificationsNotifier.value = [];
    buyerOrdersNotifier.value = [];
    sellerReceivedOrdersNotifier.value = [];
  }

  static Future<void> signOut() async {
    _clearAllSubscriptions();
    await _auth.signOut();
  }

  static void _setupAllSubscriptions(String uid) {
    _clearAllSubscriptions();

    // 1. User doc subscription
    _userSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshots) {
          if (snapshots.exists) {
            final data = snapshots.data();
            if (data != null) {
              nameNotifier.value = data['fullName'] ?? 'User';
              emailNotifier.value = data['email'] ?? '';
              phoneNotifier.value = data['phone'] ?? '';
              profileImageNotifier.value = data['profileImage'] ?? '';
              userRoleNotifier.value = data['accountType'] ?? 'Buyer';
            }
          }
        });

    // 2. Wishlist subscription (needs to be initialized early to resolve product favorites flag correctly)
    _wishlistSubscription = _firestore
        .collection('savedItems')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((wishSnapshot) {
          final List<String> favoriteIds = wishSnapshot.docs
              .map((doc) => doc.data()['productId'] as String)
              .toList();

          // Update wishlist notifier list
          final List<Product> wishlistProds = [];
          for (var pid in favoriteIds) {
            final matches = productsNotifier.value.where((p) => p.id == pid);
            if (matches.isNotEmpty) {
              wishlistProds.add(matches.first);
            }
          }
          wishlistNotifier.value = wishlistProds;

          // Update products flag
          productsNotifier.value = productsNotifier.value.map((p) {
            p.isFavorite = favoriteIds.contains(p.id);
            return p;
          }).toList();
        });

    // 3. Products subscription details
    _productsSubscription = _firestore
        .collection('products')
        .snapshots()
        .listen((prodSnapshot) {
          if (prodSnapshot.docs.isEmpty) {
            // Automatically seed products if database is fresh
            seedInitialProductsIfEmpty();
          }

          final List<Product> list = prodSnapshot.docs.map((doc) {
            final prod = Product.fromFirestore(doc.data(), doc.id);
            prod.isFavorite = wishlistNotifier.value.any(
              (w) => w.id == prod.id,
            );
            return prod;
          }).toList();

          productsNotifier.value = list;

          // Force update of wishlist based on new products list
          final List<Product> updatedWishlist = [];
          for (var w in wishlistNotifier.value) {
            final match = list.firstWhere((p) => p.id == w.id, orElse: () => w);
            updatedWishlist.add(match);
          }
          wishlistNotifier.value = updatedWishlist;
        });

    // 4. Cart subscription
    _cartSubscription = _firestore
        .collection('cart')
        .where('buyerId', isEqualTo: uid)
        .snapshots()
        .listen((cartSnapshot) {
          final List<CartItem> items = [];
          for (var doc in cartSnapshot.docs) {
            final data = doc.data();
            final productId = data['productId'] ?? '';
            final qty = data['quantity'] ?? 1;

            final matchingProd = productsNotifier.value.firstWhere(
              (p) => p.id == productId,
              orElse: () => Product(
                id: productId,
                title: data['productTitle'] ?? 'Loading...',
                price: (data['productPrice'] ?? 0.0).toDouble(),
                imageUrl: data['productImageUrl'] ?? '',
                category: data['productCategory'] ?? '',
                condition: data['productCondition'] ?? '',
                description: data['productDescription'] ?? '',
                sellerName: data['productSellerName'] ?? 'Seller',
                sellerId: data['productSellerId'],
                rating: 5.0,
                reviewsCount: 1,
              ),
            );
            items.add(CartItem(product: matchingProd, quantity: qty));
          }
          cartNotifier.value = items;
        });

    // 5. Conversations subscription
    _conversationsSubscription = _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .listen((convSnapshot) {
          final List<ChatConversation> list = [];
          for (var doc in convSnapshot.docs) {
            final data = doc.data();
            final id = doc.id;
            final buyerId = data['buyerId'] ?? '';
            final sellerId = data['sellerId'] ?? '';
            final buyerName = data['buyerName'] ?? '';
            final sellerName = data['sellerName'] ?? '';
            final productTitle = data['productTitle'] ?? '';
            final productImageUrl = data['productImageUrl'];
            final lastMessage = data['lastMessage'] ?? '';
            final unreadCountMap =
                data['unreadCount'] as Map<String, dynamic>? ?? {};

            final otherName = uid == buyerId ? sellerName : buyerName;
            final count = unreadCountMap[uid] ?? 0;

            String timeStr = 'Just now';
            if (data['lastMessageTime'] != null) {
              final t = (data['lastMessageTime'] as Timestamp).toDate();
              timeStr = _formatTimestamp(t);
            }

            list.add(
              ChatConversation(
                id: id,
                userName: otherName,
                lastMessage: lastMessage,
                lastMessageTime: timeStr,
                unreadCount: count,
                productImageUrl: productImageUrl,
                productTitle: productTitle,
                buyerId: buyerId,
                sellerId: sellerId,
                productId: data['productId'] ?? '',
                initialMessages: [],
              ),
            );
          }
          conversationsNotifier.value = list;
        });

    // 6a. Buyer Orders subscription
    _buyerOrdersSubscription = _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .snapshots()
        .listen((orderSnapshot) {
          final List<OrderModel> buyerOrdersList = [];
          for (var doc in orderSnapshot.docs) {
            final data = doc.data();
            final orderBuyerId = data['buyerId'] ?? '';
            final orderSellerId = data['sellerId'] ?? '';
            final orderBuyerName = data['buyerName'] ?? 'Buyer';
            final orderStatus = data['status'] ?? 'Pending';

            final purchaseDateObj = data['purchaseDate'];
            final dateStr = purchaseDateObj != null
                ? _formatDate((purchaseDateObj as Timestamp).toDate())
                : 'Just now';

            final prodMap = data['product'] as Map<String, dynamic>?;
            if (prodMap == null) continue;

            final qty = data['quantity'] ?? 1;
            final priceVal = (data['price'] ?? 0.0).toDouble();
            final createdAtTime = data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : (purchaseDateObj != null ? (purchaseDateObj as Timestamp).toDate() : null);
            final completedAtTime = data['completedAt'] != null
                ? (data['completedAt'] as Timestamp).toDate()
                : null;

            final ord = OrderModel(
              id: doc.id,
              orderId: "ORD-${doc.id.substring(0, 5).toUpperCase()}",
              pTitle: prodMap['title'] ?? '',
              pPrice: priceVal,
              date: dateStr,
              status: orderStatus,
              image: prodMap['imageUrl'] ?? '',
              customer: orderBuyerName,
              buyerId: orderBuyerId,
              sellerId: orderSellerId,
              productId: prodMap['id'] ?? '',
              quantity: qty,
              price: priceVal,
              createdAt: createdAtTime,
              completedAt: completedAtTime,
            );
            buyerOrdersList.add(ord);
          }
          buyerOrdersNotifier.value = buyerOrdersList;
        }, onError: (e) {
          debugPrint("Error loading buyer orders: $e");
        });

    // 6b. Seller Orders subscription
    _sellerOrdersSubscription = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: uid)
        .snapshots()
        .listen((orderSnapshot) {
          final List<OrderModel> sellerOrdersList = [];
          for (var doc in orderSnapshot.docs) {
            final data = doc.data();
            final orderBuyerId = data['buyerId'] ?? '';
            final orderSellerId = data['sellerId'] ?? '';
            final orderBuyerName = data['buyerName'] ?? 'Buyer';
            final orderStatus = data['status'] ?? 'Pending';

            final purchaseDateObj = data['purchaseDate'];
            final dateStr = purchaseDateObj != null
                ? _formatDate((purchaseDateObj as Timestamp).toDate())
                : 'Just now';

            final prodMap = data['product'] as Map<String, dynamic>?;
            if (prodMap == null) continue;

            final qty = data['quantity'] ?? 1;
            final priceVal = (data['price'] ?? 0.0).toDouble();
            final createdAtTime = data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : (purchaseDateObj != null ? (purchaseDateObj as Timestamp).toDate() : null);
            final completedAtTime = data['completedAt'] != null
                ? (data['completedAt'] as Timestamp).toDate()
                : null;

            final ord = OrderModel(
              id: doc.id,
              orderId: "ORD-${doc.id.substring(0, 5).toUpperCase()}",
              pTitle: prodMap['title'] ?? '',
              pPrice: priceVal,
              date: dateStr,
              status: orderStatus,
              image: prodMap['imageUrl'] ?? '',
              customer: orderBuyerName,
              buyerId: orderBuyerId,
              sellerId: orderSellerId,
              productId: prodMap['id'] ?? '',
              quantity: qty,
              price: priceVal,
              createdAt: createdAtTime,
              completedAt: completedAtTime,
            );
            sellerOrdersList.add(ord);
          }
          sellerReceivedOrdersNotifier.value = sellerOrdersList;
        }, onError: (e) {
          debugPrint("Error loading seller orders: $e");
        });

    _notificationsSubscription = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((notifSnapshot) {
          final docs = notifSnapshot.docs.toList();
          docs.sort((a, b) {
            final aTimeObj = a.data()['timestamp'];
            final bTimeObj = b.data()['timestamp'];
            if (aTimeObj == null && bTimeObj == null) return 0;
            if (aTimeObj == null) return 1;
            if (bTimeObj == null) return -1;
            final aTime = (aTimeObj as Timestamp).toDate();
            final bTime = (bTimeObj as Timestamp).toDate();
            return bTime.compareTo(aTime);
          });
          final list = docs
              .map((doc) => AppNotification.fromFirestore(doc.data(), doc.id))
              .toList();
          notificationsNotifier.value = list;
        });
  }

  // Seeding high-quality default data on empty DB
  static Future<void> seedInitialProductsIfEmpty() async {
    final snapshot = await _firestore.collection('products').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final initialProducts = [
      Product(
        id: "1",
        title: "Calculus Textbook",
        price: 25.00,
        imageUrl: "assets/images/calculus_textbook.jpg",
        category: "Books",
        condition: "Good",
        description:
            "Standard university Calculus textbook. Excellent condition, cover has minor wear but all pages are unmarked and clean.",
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
        description:
            "Detailed hand-written notes for College Physics. Covering Classical Mechanics, Electromagnetism, and Optics. Diagrams included.",
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
        condition: "Used",
        description:
            "Standard scientific calculator, works perfectly. Battery replaced recently. Minor scratch on screen but completely legible.",
        sellerName: "Mark Anthony",
        rating: 4.4,
        reviewsCount: 16,
      ),
      Product(
        id: "4",
        title: "Drawing Set",
        price: 8.00,
        imageUrl: "assets/images/drawing_set.jpg",
        category: "Stationery",
        condition: "New",
        description:
            "Full architectural and pencil drawing set. Includes 10 grade sketches, compass, and mechanical pencil. Sealed packing.",
        sellerName: "Stationery Mart",
        rating: 4.9,
        reviewsCount: 30,
      ),
    ];

    for (var prod in initialProducts) {
      await _firestore.collection('products').doc(prod.id).set({
        ...prod.toMap(),
        'sellerId': 'mock_seller_id',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Favorite Items persistence
  static Future<void> toggleFavorite(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('savedItems')
        .doc("${uid}_${product.id}");
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'userId': uid,
        'productId': product.id,
        'savedAt': FieldValue.serverTimestamp(),
      });
      await addNotification(
        "Item Saved",
        "Item added to Saved Items.",
        type: "System",
        userId: uid,
        relatedId: product.id,
      );
    }
  }

  // Cart operations
  static Future<void> addToCart(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('cart').doc("${uid}_${product.id}");
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final curQty = docSnapshot.data()?['quantity'] ?? 1;
      await docRef.update({'quantity': curQty + 1});
    } else {
      await docRef.set({
        'buyerId': uid,
        'productId': product.id,
        'quantity': 1,
        'productTitle': product.title,
        'productPrice': product.price,
        'productImageUrl': product.imageUrl,
        'productCategory': product.category,
        'productCondition': product.condition,
        'productDescription': product.description,
        'productSellerName': product.sellerName,
        'productSellerId': product.sellerId ?? 'mock_seller_id',
      });
    }

    await addNotification(
      "Cart Updated",
      "Item added to Cart.",
      type: "System",
      userId: uid,
      relatedId: product.id,
    );
  }

  static Future<void> removeFromCart(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('cart').doc("${uid}_${product.id}").delete();
  }

  static Future<void> incrementCartItem(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('cart').doc("${uid}_${product.id}");
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final cur = snapshot.data()?['quantity'] ?? 1;
      await docRef.update({'quantity': cur + 1});
    }
  }

  static Future<void> decrementCartItem(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('cart').doc("${uid}_${product.id}");
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final cur = snapshot.data()?['quantity'] ?? 1;
      if (cur > 1) {
        await docRef.update({'quantity': cur - 1});
      } else {
        await docRef.delete();
      }
    }
  }

  // Checkout & Orders
  static Future<void> checkout() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    // Capture unique sellers to notify
    final uniqueSellerIds = cartNotifier.value
        .map((item) => item.product.sellerId ?? 'mock_seller_id')
        .toSet();

    final batch = _firestore.batch();

    for (var item in cartNotifier.value) {
      final orderRef = _firestore.collection('orders').doc();
      batch.set(orderRef, {
        'buyerId': uid,
        'buyerName': nameNotifier.value,
        'sellerId': item.product.sellerId ?? 'mock_seller_id',
        'sellerName': item.product.sellerName,
        'price': item.product.price,
        'quantity': item.quantity,
        'purchaseDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'productId': item.product.id,
        'status': 'Pending',
        'product': {
          'id': item.product.id,
          'title': item.product.title,
          'imageUrl': item.product.imageUrl,
          'category': item.product.category,
          'condition': item.product.condition,
          'description': item.product.description,
        },
      });

      // Delete cart items
      final cartItemRef = _firestore
          .collection('cart')
          .doc("${uid}_${item.product.id}");
      batch.delete(cartItemRef);

      // Decrement stock in Firestore
      final prodRef = _firestore.collection('products').doc(item.product.id);
      final latestProd = productsNotifier.value.firstWhere(
        (p) => p.id == item.product.id,
        orElse: () => item.product,
      );
      final newStock = latestProd.stock - item.quantity;
      if (newStock <= 0) {
        batch.update(prodRef, {
          'stock': 0,
          'isSold': true,
        });

        // Trigger Out of stock notification for Seller
        await addNotification(
          "Product Out of Stock",
          "Your product '${item.product.title}' is now out of stock.",
          type: "Sales",
          userId: item.product.sellerId ?? 'mock_seller_id',
          relatedId: item.product.id,
        );
      } else {
        batch.update(prodRef, {
          'stock': newStock,
        });

        if (newStock <= 5) {
          // Trigger Low stock notification for Seller
          await addNotification(
            "Stock Low",
            "Your product '${item.product.title}' has low stock (${newStock} remaining).",
            type: "Sales",
            userId: item.product.sellerId ?? 'mock_seller_id',
            relatedId: item.product.id,
          );
        }
      }
    }

    await batch.commit();

    // Trigger Buyer Notification
    await addNotification(
      "Order Placed",
      "Your order has been placed successfully.",
      type: "Sales",
      userId: uid,
    );

    // Trigger Seller Notifications
    for (var sellerId in uniqueSellerIds) {
      await addNotification(
        "New Order",
        "You have received a new order.",
        type: "Sales",
        userId: sellerId,
      );
    }
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final Map<String, dynamic> updates = {
        'status': newStatus,
      };
      if (newStatus.toLowerCase() == 'delivered') {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }
      await _firestore.collection('orders').doc(orderId).update(updates);

      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final buyerId = data['buyerId'] as String?;
          final pTitle = data['productTitle'] as String? ?? 'your item';
          if (buyerId != null && buyerId.isNotEmpty) {
            String notifTitle = "Order Update";
            String notifBody = "Your order for \"$pTitle\" status has been updated to $newStatus.";
            if (newStatus.toLowerCase() == 'shipped') {
              notifTitle = "Order Shipped";
              notifBody = "Great news! Your order for \"$pTitle\" has been shipped.";
            } else if (newStatus.toLowerCase() == 'delivered') {
              notifTitle = "Order Delivered";
              notifBody = "Your order for \"$pTitle\" has been delivered. Enjoy it!";
            } else if (newStatus.toLowerCase() == 'cancelled') {
              notifTitle = "Order Cancelled";
              notifBody = "Your order for \"$pTitle\" has been cancelled.";
            }
            await addNotification(
              notifTitle,
              notifBody,
              type: "Sales",
              userId: buyerId,
              relatedId: orderId,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error updating order status: $e");
      rethrow;
    }
  }

  static String _formatDate(DateTime dt) {
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final dayStr = dt.day.toString().padLeft(2, '0');
    final monthStr = months[dt.month - 1];
    final yearStr = dt.year.toString();
    return "$monthStr $dayStr, $yearStr";
  }

  static bool _isLocalPath(String path) {
    return !path.startsWith('http') && !path.startsWith('assets/');
  }

  static Future<String> _uploadProductImage(
    String productId,
    String localPath,
  ) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'product_images/$productId',
      );
      UploadTask uploadTask;
      if (kIsWeb) {
        if (localPath.startsWith('data:')) {
          final uri = Uri.parse(localPath);
          final bytes = uri.data!.contentAsBytes();
          final mime = uri.data!.mimeType;
          uploadTask = storageRef.putData(
            bytes,
            SettableMetadata(contentType: mime),
          );
        } else {
          throw Exception("Unsupported web path formatting");
        }
      } else {
        uploadTask = storageRef.putFile(File(localPath));
      }
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading product image: $e");
      rethrow;
    }
  }

  // Seller Listing CRUD
  static Future<void> addProduct(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    String finalImageUrl = product.imageUrl;
    if (finalImageUrl.isNotEmpty && _isLocalPath(finalImageUrl)) {
      finalImageUrl = await _uploadProductImage(product.id, finalImageUrl);
    }

    final docRef = _firestore.collection('products').doc(product.id);
    await docRef.set({
      ...product.toMap(),
      'imageUrl': finalImageUrl,
      'sellerId': uid,
      'sellerName': nameNotifier.value,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create system notification for listing published
    await addNotification(
      "Listing Published",
      "Your listing has been published successfully.",
      type: "Sales",
      userId: uid,
      relatedId: product.id,
    );
  }

  static Future<void> editProduct(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    String finalImageUrl = product.imageUrl;
    if (finalImageUrl.isNotEmpty && _isLocalPath(finalImageUrl)) {
      finalImageUrl = await _uploadProductImage(product.id, finalImageUrl);
    }

    final data = product.toMap();
    data['imageUrl'] = finalImageUrl;

    await _firestore.collection('products').doc(product.id).update(data);
  }

  static Future<void> deleteProduct(String id) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'product_images/$id',
      );
      await storageRef.delete();
    } catch (e) {
      debugPrint("Error deleting product image from storage: $e");
    }
    await _firestore.collection('products').doc(id).delete();
  }

  static Future<void> markItemSold(String id) async {
    await _firestore.collection('products').doc(id).update({'isSold': true});
  }

  // Messages real-time handling
  static void listenToMessages(String conversationId) {
    _activeMessagesSubscription?.cancel();
    final uid = currentUser?.uid;
    if (uid == null) return;

    final convIndex = conversationsNotifier.value.indexWhere(
      (c) => c.id == conversationId,
    );
    if (convIndex < 0) return;
    final conv = conversationsNotifier.value[convIndex];

    _activeMessagesSubscription = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((msgSnapshot) {
          final list = msgSnapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc.data(), uid))
              .toList();
          conv.messagesNotifier.value = list;

          // Automatically reset unread count for current user
          _resetUnreadCount(conversationId, uid);
        });
  }

  static void stopListeningToMessages() {
    _activeMessagesSubscription?.cancel();
  }

  static Future<void> _resetUnreadCount(
    String conversationId,
    String uid,
  ) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount.$uid': 0,
    });
  }

  static Future<void> addMessage(
    String convId,
    String text, {
    bool isMe = true,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final convDoc = await _firestore
        .collection('conversations')
        .doc(convId)
        .get();
    if (!convDoc.exists) return;

    final convData = convDoc.data()!;
    final buyerId = convData['buyerId'] ?? '';
    final sellerId = convData['sellerId'] ?? '';
    final otherUid = uid == buyerId ? sellerId : buyerId;

    final messageRef = _firestore
        .collection('conversations')
        .doc(convId)
        .collection('messages')
        .doc();

    final batch = _firestore.batch();

    batch.set(messageRef, {
      'messageId': messageRef.id,
      'conversationId': convId,
      'senderId': uid,
      'receiverId': otherUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update conversation state & trigger unread trigger count for recipient
    batch.update(_firestore.collection('conversations').doc(convId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$otherUid': FieldValue.increment(1),
    });

    await batch.commit();

    // Trigger Notification automatically
    final notificationTitle = uid == buyerId
        ? "New message from Buyer"
        : "New message from Seller";

    await addNotification(
      notificationTitle,
      text,
      type: "Messages",
      userId: otherUid,
      relatedId: convId,
    );
  }

  // Create chat conversation dynamically on Buyer Detail screen action
  static Future<String> startOrGetConversation(Product product) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception("User is not signed in.");

    final sellerId = product.sellerId ?? 'mock_seller_id';
    final sellerName = product.sellerName;
    final buyerName = nameNotifier.value;

    if (uid == sellerId) {
      throw Exception("You cannot chat with yourself.");
    }

    // Search query for matching conversation doc config
    final existingConv = await _firestore
        .collection('conversations')
        .where('buyerId', isEqualTo: uid)
        .where('sellerId', isEqualTo: sellerId)
        .where('productId', isEqualTo: product.id)
        .limit(1)
        .get();

    if (existingConv.docs.isNotEmpty) {
      return existingConv.docs.first.id;
    }

    final newConvDoc = _firestore.collection('conversations').doc();
    await newConvDoc.set({
      'buyerId': uid,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'productId': product.id,
      'productTitle': product.title,
      'productImageUrl': product.imageUrl,
      'lastMessage': 'Chat started.',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [uid, sellerId],
      'unreadCount': {uid: 0, sellerId: 0},
    });

    return newConvDoc.id;
  }

  // Notifications API details
  static Future<void> addNotification(
    String title,
    String body, {
    String type = "System",
    String? userId,
    String? relatedId,
  }) async {
    final targetUid = userId ?? currentUser?.uid;
    if (targetUid == null) return;

    final docRef = _firestore.collection('notifications').doc();
    await docRef.set({
      'notificationId': docRef.id,
      'userId': targetUid,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> markNotificationAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({
      'isRead': true,
    });
  }

  static Future<void> removeNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }

  static Future<void> clearAllNotifications() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final notifs = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .get();

    final batch = _firestore.batch();
    for (var doc in notifs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static String _formatTimestamp(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays > 0) {
      return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
    } else if (diff.inHours > 0) {
      return "${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes} min ago";
    } else {
      return "Just now";
    }
  }

  static Future<void> uploadAndUpdateProfileImage(String localPath) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/$uid',
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        if (localPath.startsWith('data:')) {
          final uri = Uri.parse(localPath);
          final bytes = uri.data!.contentAsBytes();
          uploadTask = storageRef.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          throw Exception("Unsupported web path formatting");
        }
      } else {
        uploadTask = storageRef.putFile(File(localPath));
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'profileImage': downloadUrl,
      });

      profileImageNotifier.value = downloadUrl;
    } catch (e) {
      debugPrint("Error uploading profile image: $e");
      rethrow;
    }
  }
}
