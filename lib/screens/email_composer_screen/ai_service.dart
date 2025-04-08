import 'dart:async';
import 'email_draft.dart';

class AIService {
  static Future<String> generateText(String actionType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In a real app, this would call an AI API
    switch (actionType) {
      case 'Thanks':
        return '\n\nCảm ơn bạn rất nhiều vì sự hỗ trợ và hợp tác. Tôi rất trân trọng điều này.\n\nTrân trọng,\n';
      case 'Sorry':
        return '\n\nTôi xin chân thành xin lỗi về sự bất tiện này. Chúng tôi sẽ nỗ lực để đảm bảo điều này không xảy ra trong tương lai.\n\nTrân trọng,\n';
      case 'Yes':
        return '\n\nVâng, tôi đồng ý với đề xuất của bạn. Chúng ta có thể tiến hành các bước tiếp theo.\n\nTrân trọng,\n';
      case 'No':
        return '\n\nTôi rất tiếc, nhưng chúng tôi không thể chấp nhận đề xuất này vào thời điểm hiện tại. Tuy nhiên, chúng tôi đánh giá cao cơ hội và mong muốn hợp tác trong tương lai.\n\nTrân trọng,\n';
      case 'Follow Up':
        return '\n\nTôi xin phép được theo dõi về vấn đề chúng ta đã thảo luận trước đó. Bạn đã có cơ hội xem xét đề xuất của chúng tôi chưa?\n\nTrân trọng,\n';
      case 'Request':
        return '\n\nTôi cần thêm thông tin về vấn đề này để có thể hỗ trợ bạn tốt hơn. Cụ thể, bạn có thể cung cấp:\n\n1. [Thông tin cần thiết 1]\n2. [Thông tin cần thiết 2]\n\nTrân trọng,\n';
      default:
        return '';
    }
  }

  static Future<EmailDraft> generateDraft({
    required String actionType,
    required String to,
    required String subject,
    required String currentBody,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would call an AI API
    String generatedBody = '';
    
    switch (actionType) {
      case 'Thanks':
        generatedBody = '''
Kính gửi ${to.isEmpty ? 'Quý đối tác' : to},

${currentBody.isNotEmpty ? '$currentBody\n\n' : ''}Tôi xin gửi lời cảm ơn chân thành đến bạn vì sự hỗ trợ và hợp tác trong thời gian qua. Sự đóng góp của bạn đã giúp chúng tôi đạt được những kết quả tốt đẹp.

Chúng tôi rất trân trọng mối quan hệ hợp tác này và mong muốn tiếp tục làm việc cùng nhau trong tương lai.

Trân trọng,
[Tên của bạn]
''';
        break;
      case 'Sorry':
        generatedBody = '''
Kính gửi ${to.isEmpty ? 'Quý đối tác' : to},

${currentBody.isNotEmpty ? '$currentBody\n\n' : ''}Tôi xin gửi lời xin lỗi chân thành về sự bất tiện đã xảy ra. Chúng tôi hiểu rằng điều này có thể gây ảnh hưởng đến công việc của bạn và chúng tôi đang nỗ lực khắc phục tình huống này trong thời gian sớm nhất.

Chúng tôi cam kết sẽ cải thiện quy trình làm việc để đảm bảo vấn đề tương tự không tái diễn trong tương lai.

Trân trọng,
[Tên của bạn]
''';
        break;
      case 'Yes':
        generatedBody = '''
Kính gửi ${to.isEmpty ? 'Quý đối tác' : to},

${currentBody.isNotEmpty ? '$currentBody\n\n' : ''}Tôi xin phản hồi về đề xuất của bạn với câu trả lời là "Có". Chúng tôi đồng ý với các điều khoản và điều kiện đã được đề cập và sẵn sàng tiến hành các bước tiếp theo.

Vui lòng cho chúng tôi biết nếu bạn cần thêm thông tin hoặc có bất kỳ câu hỏi nào.

Trân trọng,
[Tên của bạn]
''';
        break;
      case 'No':
        generatedBody = '''
Kính gửi ${to.isEmpty ? 'Quý đối tác' : to},

${currentBody.isNotEmpty ? '$currentBody\n\n' : ''}Sau khi cân nhắc kỹ lưỡng, tôi rất tiếc phải thông báo rằng chúng tôi không thể chấp nhận đề xuất hiện tại. Mặc dù chúng tôi đánh giá cao cơ hội này, nhưng vào thời điểm hiện tại, nó không phù hợp với định hướng và nguồn lực của chúng tôi.

Chúng tôi vẫn mong muốn duy trì mối quan hệ tốt đẹp và sẵn sàng xem xét các cơ hội hợp tác khác trong tương lai.

Trân trọng,
[Tên của bạn]
''';
        break;
      case 'Follow Up':
        generatedBody = '''
Kính gửi ${to.isEmpty ? 'Quý đối tác' : to},

${currentBody.isNotEmpty ? '$currentBody\n\n' : ''}Tôi xin phép được theo dõi về vấn đề chúng ta đã thảo luận trước đó. Chúng tôi đang rất mong nhận được phản hồi hoặc cập nhật từ phía bạn để có thể tiến hành các bước tiếp theo.

Nếu bạn cần thêm thông tin hoặc có bất kỳ câu hỏi nào, vui lòng liên hệ với tôi. Tôi sẵn sàng hỗ trợ để đảm bảo mọi việc diễn ra suôn sẻ.

Trân trọng,
[Tên của bạn]
''';
        break;
      case 'Request Info':
        generatedBody = '''
Kính gửi ${to.isEmpty ? 'Quý đối tác' : to},

${currentBody.isNotEmpty ? '$currentBody\n\n' : ''}Liên quan đến dự án/vấn đề hiện tại, chúng tôi cần thêm một số thông tin để có thể tiến hành các bước tiếp theo một cách hiệu quả. Cụ thể, chúng tôi cần:

1. [Thông tin cần thiết 1]
2. [Thông tin cần thiết 2]
3. [Thông tin cần thiết 3]

Việc cung cấp những thông tin này sẽ giúp chúng tôi đánh giá tình hình chính xác hơn và đưa ra các quyết định phù hợp.

Trân trọng,
[Tên của bạn]
''';
        break;
      default:
        generatedBody = currentBody;
    }
    
    return EmailDraft(
      to: to,
      subject: subject.isEmpty ? 'Re: ' : subject,
      body: generatedBody,
    );
  }
}

