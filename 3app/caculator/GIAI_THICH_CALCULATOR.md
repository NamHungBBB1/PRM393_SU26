# Giải thích chi tiết calculator.dart

---

## 1. Import & main()

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
```



---

## 2. MyApp & CalculatorPage

Cấu trúc `StatelessWidget` (MyApp) bao `StatefulWidget` (CalculatorPage) hoàn toàn giống file random.  
Lý do dùng `StatefulWidget`: kết quả tính toán thay đổi theo input của user → cần rebuild UI.

---

## 3. Các biến State

```dart
final _num1Controller = TextEditingController();
final _num2Controller = TextEditingController();
String _selectedOperator = '+';
String _result = '';
final List<String> _operators = ['+', '-', '*', '/'];
```

| Biến | Kiểu | Ý nghĩa |
|---|---|---|
| `_num1Controller` | `TextEditingController` | Đọc giá trị ô nhập Số 1 |
| `_num2Controller` | `TextEditingController` | Đọc giá trị ô nhập Số 2 |
| `_selectedOperator` | `String` | Phép tính đang được chọn, mặc định là `+` |
| `_result` | `String` | Kết quả hiển thị ra màn hình |
| `_operators` | `List<String>` | Danh sách 4 phép tính để tạo dropdown |

> **Tại sao `_result` là String thay vì double?**  
> Vì cần hiển thị cả thông báo lỗi ("Vui lòng nhập số...") lẫn kết quả số trong cùng 1 biến.

---

## 4. Hàm _calculate() — core logic

### Bước 1: Parse input

```dart
final double? num1 = double.tryParse(_num1Controller.text);
final double? num2 = double.tryParse(_num2Controller.text);
```

- Dùng `double` thay vì `int` để hỗ trợ số thập phân (vd: 3.5 + 1.2)
- `double.tryParse()` trả về `null` nếu text không phải số hợp lệ

### Bước 2: Validate

```dart
if (num1 == null || num2 == null) {
  setState(() => _result = 'Vui lòng nhập số hợp lệ');
  return;
}

if (_selectedOperator == '/' && num2 == 0) {
  setState(() => _result = 'Không thể chia cho 0');
  return;
}
```

- Kiểm tra null trước khi tính — bắt buộc vì `tryParse` có thể trả về null
- Kiểm tra chia cho 0 riêng vì đây là lỗi toán học đặc biệt
- Dùng `return` để thoát hàm ngay, không chạy tiếp phần tính

### Bước 3: Tính toán với switch

```dart
double answer;
switch (_selectedOperator) {
  case '+':
    answer = num1 + num2;
  case '-':
    answer = num1 - num2;
  case '*':
    answer = num1 * num2;
  case '/':
    answer = num1 / num2;
  default:
    return;
}
```

- `switch` kiểm tra giá trị của `_selectedOperator` và chạy đúng case tương ứng
- `default:` xử lý trường hợp không khớp case nào (thực tế không bao giờ xảy ra vì dropdown chỉ có 4 giá trị cố định)

### Bước 4: Format và cập nhật kết quả

```dart
setState(() {
  _result = answer % 1 == 0 ? answer.toInt().toString() : answer.toString();
});
```

- `answer % 1 == 0` — kiểm tra xem kết quả có phải số nguyên không (phần dư khi chia cho 1 bằng 0)
- Nếu đúng: `.toInt().toString()` → hiện `6` thay vì `6.0`
- Nếu không: `.toString()` → hiện `3.5`
- Toán tử `? :` là **ternary operator**: `điều_kiện ? giá_trị_nếu_đúng : giá_trị_nếu_sai`

---

## 5. Widget mới so với file random

### DropdownButtonFormField

```dart
DropdownButtonFormField<String>(
  value: _selectedOperator,
  decoration: const InputDecoration(
    labelText: 'Phép tính',
    border: OutlineInputBorder(),
  ),
  items: _operators.map((op) {
    return DropdownMenuItem(value: op, child: Text(op));
  }).toList(),
  onChanged: (value) {
    setState(() => _selectedOperator = value!);
  },
),
```

Đây là widget **dropdown** (danh sách xổ xuống).

| Prop | Ý nghĩa |
|---|---|
| `value:` | Giá trị đang được chọn (liên kết với biến state) |
| `items:` | Danh sách các lựa chọn |
| `onChanged:` | Callback khi user chọn item khác |

**Dòng quan trọng:**
```dart
items: _operators.map((op) {
  return DropdownMenuItem(value: op, child: Text(op));
}).toList(),
```
- `_operators.map(...)` — duyệt qua từng phần tử trong list và biến đổi nó
- Mỗi `String` trong list được chuyển thành 1 `DropdownMenuItem`
- `.toList()` — chuyển kết quả `map` (là `Iterable`) về `List` vì `items:` yêu cầu `List`

**Dòng `value!`:**
```dart
setState(() => _selectedOperator = value!);
```
- `onChanged` nhận `String?` (nullable) vì Flutter không chắc user có chọn hay không
- `!` là **null assertion operator**: khẳng định với Dart rằng `value` không phải null tại đây (an toàn vì dropdown luôn có giá trị)

---

## 6. Hiển thị kết quả có điều kiện

```dart
Text(
  _result.isEmpty ? '' : 'Kết quả: $_result',
  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
)
```

- `_result.isEmpty` — kiểm tra chuỗi rỗng
- Khi chưa bấm tính (`_result == ''`) → hiện chuỗi rỗng → widget Text vẫn tồn tại nhưng không thấy gì
- Sau khi tính → hiện `Kết quả: 42`

> **Tại sao không dùng `if (_result.isNotEmpty) Text(...)` ?**  
> Được, cũng không sai. Nhưng dùng ternary trong Text giúp giữ layout ổn định hơn — widget luôn tồn tại, chỉ thay đổi text, tránh layout bị giật khi widget xuất hiện/biến mất.

---

## So sánh với file random

| Điểm | random.dart | calculator.dart |
|---|---|---|
| Widget mới học | — | `DropdownButtonFormField`, `List.map()` |
| Kiểu số | `int` | `double` |
| Parse input | `int.tryParse()` | `double.tryParse()` |
| Logic chính | `Random().nextInt()` | `switch` + toán tử số học |
| Biến kết quả | `int?` | `String` |
| Validate | min > max | null check + chia cho 0 |

---

## Tổng kết luồng chạy

```
Khởi động
  └── build() → vẽ 2 TextField + Dropdown + Button + Text rỗng

[User nhập số và chọn phép tính]
  └── Dropdown onChanged → setState → _selectedOperator cập nhật

[User bấm "Tính"]
  └── _calculate()
        ├── Parse num1, num2
        ├── Validate (null? chia 0?)
        ├── switch → tính answer
        └── setState(_result = ...) → build() chạy lại → Text hiện kết quả
```

---

## Các khái niệm Flutter/Dart mới trong file này

| Khái niệm | Ý nghĩa |
|---|---|
| `double.tryParse()` | Parse string → double, trả null nếu lỗi |
| `switch / case` | Rẽ nhánh theo giá trị cụ thể |
| `List<String>` | Danh sách kiểu String |
| `.map().toList()` | Biến đổi từng phần tử trong list |
| `DropdownButtonFormField` | Widget dropdown chọn từ danh sách |
| `value!` (null assertion) | Khẳng định giá trị không phải null |
| `answer % 1 == 0` | Kiểm tra số nguyên |
| `.toInt()` | Chuyển double → int |
| `String.isEmpty` | Kiểm tra chuỗi rỗng |