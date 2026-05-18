# Giải thích chi tiết main.dart

---

## 1. Import

```dart
import 'package:flutter/material.dart';
import 'dart:math';
```

- `flutter/material.dart` — thư viện UI chính của Flutter, cung cấp toàn bộ widget (Text, Button, TextField...).
- `dart:math` — thư viện Dart cung cấp class `Random` để sinh số ngẫu nhiên.

---

## 2. Hàm main()

```dart
void main() {
  runApp(const MyApp());
}
```

- `main()` là điểm khởi chạy của mọi ứng dụng Dart/Flutter.
- `runApp()` nhận vào 1 widget gốc và "gắn" nó lên màn hình. Toàn bộ UI của app sẽ là con cháu của widget này.

---

## 3. MyApp — StatelessWidget

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RandomPage(),
    );
  }
}
```

### StatelessWidget là gì?
Widget **không có state** — tức là nó chỉ render 1 lần, không thay đổi theo thời gian.  
Dùng khi widget chỉ hiển thị thông tin tĩnh, không cần cập nhật.

### MaterialApp
Widget "wrapper" bao toàn bộ app. Nó cung cấp:
- Theme, màu sắc mặc định
- Navigation (đẩy/pop màn hình)
- `debugShowCheckedModeBanner: false` — ẩn banner "DEBUG" ở góc màn hình
- `home:` — màn hình đầu tiên được hiển thị

---

## 4. RandomPage — StatefulWidget

```dart
class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}
```

### StatefulWidget là gì?
Widget **có state** — có thể thay đổi giao diện theo thời gian (ví dụ: sau khi bấm nút).

StatefulWidget luôn đi kèm với 1 class State riêng. Flutter tách ra như vậy vì:
- `StatefulWidget` = cấu hình (bất biến)
- `State` = dữ liệu thay đổi được + hàm `build()`

`createState()` là hàm bắt buộc phải override, nó tạo ra object State tương ứng.

---

## 5. _RandomPageState — State

```dart
class _RandomPageState extends State<RandomPage> {
  final _minController = TextEditingController(text: '1');
  final _maxController = TextEditingController(text: '100');
  int? _result;
  ...
}
```

Đây là nơi chứa toàn bộ **dữ liệu** và **logic** của màn hình.

### Các biến state

| Biến | Kiểu | Ý nghĩa |
|---|---|---|
| `_minController` | `TextEditingController` | Kết nối với TextField Min, đọc/ghi giá trị text |
| `_maxController` | `TextEditingController` | Kết nối với TextField Max |
| `_result` | `int?` | Kết quả random. `?` nghĩa là nullable (có thể null khi chưa generate) |

### TextEditingController
Là object dùng để **đọc và điều khiển nội dung** của TextField từ code.  
Khởi tạo với `text: '1'` nghĩa là TextField ban đầu hiển thị sẵn số 1.

---

## 6. Hàm _generate()

```dart
void _generate() {
  final min = int.tryParse(_minController.text) ?? 1;
  final max = int.tryParse(_maxController.text) ?? 100;

  if (min > max) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Min phải nhỏ hơn hoặc bằng Max')),
    );
    return;
  }

  setState(() {
    _result = min + Random().nextInt(max - min + 1);
  });
}
```

**Đây là core logic của app**, chạy khi người dùng bấm nút.

### Từng dòng

```dart
final min = int.tryParse(_minController.text) ?? 1;
```
- `_minController.text` — lấy chuỗi text trong TextField
- `int.tryParse(...)` — cố parse sang số nguyên, trả về `null` nếu không hợp lệ
- `?? 1` — toán tử null-coalescing: nếu kết quả là null thì dùng giá trị mặc định là `1`

```dart
if (min > max) { ... return; }
```
- Validate: min không được lớn hơn max
- `ScaffoldMessenger.of(context).showSnackBar(...)` — hiện thanh thông báo ở đáy màn hình

```dart
setState(() {
  _result = min + Random().nextInt(max - min + 1);
});
```
- `Random().nextInt(n)` — sinh số ngẫu nhiên trong khoảng `[0, n-1]`
- Công thức `min + Random().nextInt(max - min + 1)` → kết quả nằm trong `[min, max]`
- `setState()` — **bắt buộc phải gọi** khi muốn cập nhật UI. Flutter sẽ gọi lại `build()` sau khi `setState` chạy xong

> **Tại sao phải dùng setState?**  
> Flutter không tự động theo dõi biến thay đổi. Gọi `setState` là cách báo cho Flutter biết "dữ liệu đã thay đổi, hãy render lại".

---

## 7. dispose()

```dart
@override
void dispose() {
  _minController.dispose();
  _maxController.dispose();
  super.dispose();
}
```

- `dispose()` được Flutter gọi khi widget bị xóa khỏi cây (ví dụ: đóng màn hình).
- Phải gọi `.dispose()` trên các Controller để **giải phóng bộ nhớ**, tránh memory leak.
- `super.dispose()` — gọi dispose của class cha, bắt buộc.

---

## 8. build() — vẽ UI

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(...);
}
```

- `build()` là hàm Flutter gọi **mỗi khi cần render** widget này (lần đầu và sau mỗi `setState`).
- Trả về một cây widget mô tả giao diện.
- `BuildContext context` — đối tượng chứa thông tin về vị trí của widget trong cây, dùng để truy cập Theme, Navigator, MediaQuery...

### Scaffold
Khung cơ bản của một màn hình Material. Cung cấp:
- `appBar:` — thanh tiêu đề trên cùng
- `body:` — nội dung chính

### Padding
```dart
Padding(padding: const EdgeInsets.all(24), child: ...)
```
Thêm khoảng cách 24px xung quanh widget con.

### Column
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [...],
)
```
Xếp các widget con theo chiều dọc.  
`mainAxisAlignment: center` — căn giữa theo chiều dọc.

### Text (hiển thị kết quả)
```dart
Text(
  _result != null ? '$_result' : '?',
  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
)
```
- Dùng **ternary operator**: nếu có kết quả thì hiện số, chưa có thì hiện `?`
- `'$_result'` — string interpolation, chèn giá trị biến vào chuỗi

### TextField
```dart
TextField(
  controller: _minController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Min',
    border: OutlineInputBorder(),
  ),
)
```
- `controller:` — kết nối với TextEditingController để đọc giá trị
- `keyboardType: TextInputType.number` — bàn phím số khi focus vào ô này
- `InputDecoration` — trang trí: label nổi lên khi focus, viền xung quanh

### ElevatedButton
```dart
ElevatedButton(
  onPressed: _generate,
  child: const Text('Generate'),
)
```
- `onPressed:` — callback khi người dùng bấm. Truyền thẳng tên hàm (không gọi)
- `child:` — widget hiển thị bên trong nút

---

## Tổng kết luồng chạy

```
main()
  └── runApp(MyApp)
        └── MaterialApp
              └── RandomPage (StatefulWidget)
                    └── _RandomPageState
                          ├── build() → vẽ UI lần đầu
                          └── [user bấm nút]
                                └── _generate()
                                      └── setState() → Flutter gọi lại build() → UI cập nhật
```

---

## Các khái niệm Flutter core được dùng

| Khái niệm | Widget/Class | Dùng để |
|---|---|---|
| Entry point | `main()` + `runApp()` | Khởi động app |
| App root | `MaterialApp` | Cấu hình toàn app |
| Static UI | `StatelessWidget` | Widget không đổi |
| Dynamic UI | `StatefulWidget` + `State` | Widget có thể cập nhật |
| Rebuild UI | `setState()` | Trigger render lại |
| Layout | `Column`, `Padding` | Sắp xếp widget |
| Input | `TextField` + `TextEditingController` | Nhận input từ user |
| Output | `Text` | Hiển thị text |
| Action | `ElevatedButton` | Bắt sự kiện bấm |
| Memory | `dispose()` | Dọn dẹp tài nguyên |
| Notification | `SnackBar` | Thông báo ngắn |