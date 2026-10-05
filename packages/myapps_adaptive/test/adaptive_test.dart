import 'package:myapps_adaptive/myapps_adaptive.dart';
import 'package:test/test.dart';

/// Purpose: Verify split boundaries and content packing contracts.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers tests.
/// Notes: Window shape and content capacity are independent.
void main() {
  test('split thresholds and window orientations', () {
    expect(canSplitLayout(599, 600), isFalse);
    expect(canSplitLayout(600, 600), isTrue);
    expect(canSplitLayout(800, 479), isFalse);
    expect(canSplitLayout(800, 480), isTrue);
    expect(canSplitLayout(819, 1000), isFalse);
    expect(canSplitLayout(820, 1000), isTrue);
    expect(canSplitLayout(704, 933), isFalse);
    expect(canSplitLayout(933, 704), isTrue);
    expect(canSplitLayout(659, 791), isTrue);
    expect(canSplitLayout(791, 820), isTrue);
    expect(canSplitLayout(768, 1024), isFalse);
    expect(canSplitLayout(1024, 768), isTrue);
    expect(canSplitLayout(915, 412), isFalse);
    expect(useNavigationRail(915), isTrue);
    expect(useNavigationRail(599), isFalse);
    expect(useNavigationRail(600), isTrue);
  });
  test('capacity pays only for gaps between columns', () {
    expect(columnCapacity(651, minItemWidth: 320), 1);
    expect(columnCapacity(652, minItemWidth: 320), 2);
    expect(columnCapacity(2000, minItemWidth: 320), 4);
    expect(columnCapacity(2000, minItemWidth: 320, maxColumns: 2), 2);
    expect(columnCapacity(0, minItemWidth: 320), 1);
    expect(columnCapacity(100, minItemWidth: 0), 4);
    expect(columnCapacity(100, minItemWidth: 320, maxColumns: 0), 1);
    expect(listRowCount(0, 2), 0);
    expect(listRowCount(5, 2), 3);
    expect(listRowCount(5, 0), 5);
  });
}
