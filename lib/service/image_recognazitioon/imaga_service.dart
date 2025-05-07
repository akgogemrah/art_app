import 'dart:convert';
import 'package:http/http.dart' as http;

class ImaggaService {
  static const String _baseUrl = 'https://api.imagga.com/v2';

  // Imagga API kimlik bilgilerinizi buraya ekleyin
  static const String _apiKey = 'acc_de94b0361316859';
  static const String _apiSecret = '3d5e7a31d7284bc541ebfef2551a3379'; // API Secret değiştirdim

  // Basic auth için kimlik bilgilerini encode et
  static String get _basicAuth {
    final String credentials = '$_apiKey:$_apiSecret';
    final String encoded = base64Encode(utf8.encode(credentials));
    return "Basic $encoded"; // Dinamik olarak oluşturuyoruz
  }

  // Görüntü URL'sinden etiketleri almak için
  static Future<Map<String, dynamic>> getTags(String imageUrl) async {
    try {
      // URL'nin doğru şekilde kodlandığından emin olalım
      final encodedUrl = Uri.encodeComponent(imageUrl);

      final response = await http.get(
        Uri.parse('$_baseUrl/tags?image_url=$encodedUrl'),
        headers: {'Authorization': _basicAuth},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Imagga API Hatası: ${response.statusCode}');
        print('Yanıt: ${response.body}');
        return {'error': 'API yanıt hatası: ${response.statusCode}', 'body': response.body};
      }
    } catch (e) {
      print('Imagga API İstek Hatası: $e');
      return {'error': 'İstek hatası: $e'};
    }
  }

  // Görüntü URL'sinden renk analizi almak için
  static Future<Map<String, dynamic>> getColors(String imageUrl) async {
    try {
      // URL'nin doğru şekilde kodlandığından emin olalım
      final encodedUrl = Uri.encodeComponent(imageUrl);

      final response = await http.get(
        Uri.parse('$_baseUrl/colors?image_url=$encodedUrl'),
        headers: {'Authorization': _basicAuth},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Imagga API Renk Hatası: ${response.statusCode}');
        print('Yanıt: ${response.body}');
        return {'error': 'API yanıt hatası: ${response.statusCode}', 'body': response.body};
      }
    } catch (e) {
      print('Imagga API Renk İstek Hatası: $e');
      return {'error': 'İstek hatası: $e'};
    }
  }

  // Görüntü analiz sonuçlarından anlamlı bir açıklama oluşturmak için
  static String generateDescription(Map<String, dynamic> tagsData, Map<String, dynamic> colorsData) {
    String description = '';

    try {
      // Etiketleri işle
      if (tagsData.containsKey('result') &&
          tagsData['result'].containsKey('tags') &&
          tagsData['result']['tags'].isNotEmpty) {

        final tags = tagsData['result']['tags'];

        // En yüksek güven skoruna sahip 5 etiketi al
        final topTags = tags.take(5).map((tag) => tag['tag']['en']).toList();

        description += 'Bu eserde öne çıkan unsurlar: ${topTags.join(", ")}. ';
      }

      // Renkleri işle
      if (colorsData.containsKey('result') &&
          colorsData['result'].containsKey('colors') &&
          colorsData['result']['colors'].containsKey('foreground_colors') &&
          colorsData['result']['colors']['foreground_colors'].isNotEmpty) {

        final foregroundColors = colorsData['result']['colors']['foreground_colors'];

        // En baskın 3 rengi al - burada name'i doğru şekilde alıyoruz
        final dominantColors = foregroundColors.take(3).map((color) {
          // closest_palette_color bir harita olduğundan name'i doğru şekilde alıyoruz
          if (color.containsKey('closest_palette_color') &&
              color['closest_palette_color'] is Map &&
              color['closest_palette_color'].containsKey('name')) {
            return _translateColor(color['closest_palette_color']['name']);
          }
          return "bilinmeyen";
        }).toList();

        description += 'Eserde ağırlıklı olarak ${dominantColors.join(", ")} renkleri kullanılmıştır. ';
      }

      // Açıklama çok kısa ise varsayılan bir metin ekle
      if (description.isEmpty) {
        description = 'Bu eser, dijital ortamda analiz edilmiştir. Detaylı bilgi için sanatçı ile iletişime geçebilirsiniz.';
      } else {
        description += 'Bu analiz, yapay zeka destekli görüntü tanıma teknolojisi kullanılarak oluşturulmuştur.';
      }

      return description;
    } catch (e) {
      print('Açıklama oluşturma hatası: $e');
      return 'Bu eser için otomatik açıklama oluşturulurken bir hata meydana geldi.';
    }
  }

  // İngilizce renk isimlerini Türkçe'ye çevirmek için helper fonksiyon
  static String _translateColor(String colorName) {
    final colorMap = {
      'red': 'kırmızı',
      'blue': 'mavi',
      'green': 'yeşil',
      'yellow': 'sarı',
      'orange': 'turuncu',
      'purple': 'mor',
      'pink': 'pembe',
      'brown': 'kahverengi',
      'gray': 'gri',
      'grey': 'gri',
      'black': 'siyah',
      'white': 'beyaz',
      'beige': 'bej',
      'cyan': 'camgöbeği',
      'magenta': 'eflatun',
      'gold': 'altın',
      'silver': 'gümüş',
      'navy': 'lacivert',
      'teal': 'çamurcun mavisi',
    };

    // Renk isminde birden fazla kelime varsa her birini çevirmeye çalış
    List<String> parts = colorName.toLowerCase().split(' ');
    List<String> translated = [];

    for (var part in parts) {
      if (colorMap.containsKey(part)) {
        translated.add(colorMap[part]!);
      } else {
        translated.add(part); // Çevirisi yoksa olduğu gibi bırak
      }
    }

    return translated.join(' ');
  }
}