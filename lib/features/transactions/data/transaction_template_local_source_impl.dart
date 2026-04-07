import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/transaction_template_entity.dart';
import 'transaction_template_local_source.dart';

class TransactionTemplateLocalSourceImpl
    implements TransactionTemplateLocalSource {
  TransactionTemplateLocalSourceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'transaction_templates';

  @override
  Future<List<TransactionTemplateEntity>> getTemplates() async {
    final strList = _prefs.getStringList(_key) ?? [];
    return strList
        .map(
          (s) => TransactionTemplateEntity.fromJson(
            jsonDecode(s) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> addTemplate(TransactionTemplateEntity template) async {
    final templates = await getTemplates();
    templates.add(template);
    await _save(templates);
  }

  @override
  Future<void> updateTemplate(TransactionTemplateEntity template) async {
    final templates = await getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
      await _save(templates);
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == id);
    await _save(templates);
  }

  Future<void> _save(List<TransactionTemplateEntity> templates) async {
    final strList = templates.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_key, strList);
  }
}
