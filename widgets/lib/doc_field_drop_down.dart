import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:providers/firestore.dart';

class _GenericStateNotifier<V> extends StateNotifier<V> {
  _GenericStateNotifier(V d) : super(d);

  set value(V v) {
    state = v;
  }

  V get value => state;
}

class DocFieldDropDown extends ConsumerWidget {
  final DocumentReference docRef;
  final String field;

  final Function(String?)? onChanged;
  final StateNotifierProvider<_GenericStateNotifier<String?>, String?> valueNP;
  final List<String> items;

  const DocFieldDropDown(this.docRef, this.field, this.valueNP, this.items,
      {this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(docSP(docRef.path)).when(
          loading: () => Container(),
          error: (e, s) => ErrorWidget(e),
          data: (doc) => DropdownButton<String>(
                value: doc.data()![field],
                onChanged: (String? newValue) {
                  docRef.update({field: newValue});

                  ref.read(valueNP.notifier).value = newValue;

                  if (onChanged != null) onChanged!(newValue);
                },
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ));
}