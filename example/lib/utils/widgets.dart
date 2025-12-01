import 'package:flutter/material.dart';
import 'package:situm_flutter/sdk.dart';

class ButtonsGroupWithSelector extends StatefulWidget {
  final IconData iconData;
  final String title;
  final List<Widget> children;
  final ValueNotifier<List<NamedResource>> selectorItems;
  final void Function(NamedResource) callback;

  const ButtonsGroupWithSelector({
    super.key,
    required this.iconData,
    required this.title,
    required this.children,
    required this.selectorItems,
    required this.callback,
  });

  @override
  State<ButtonsGroupWithSelector> createState() =>
      _ButtonsGroupWithSelectorState();
}

class _ButtonsGroupWithSelectorState extends State<ButtonsGroupWithSelector> {
  NamedResource? selected;

  @override
  void initState() {
    super.initState();
    _ensureValidSelection(widget.selectorItems.value);
  }

  void _ensureValidSelection(List<NamedResource> items) {
    if (items.isEmpty) {
      selected = null;
      return;
    }
    if (selected == null || !items.contains(selected)) {
      selected = items.first;
    }
  }

  Future<void> _openSelector(List<NamedResource> items) async {
    final result = await showModalBottomSheet<NamedResource>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() => selected = result);
      widget.callback(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        title: CardTitle(iconData: widget.iconData, title: widget.title),
        children: [
          ValueListenableBuilder<List<NamedResource>>(
            valueListenable: widget.selectorItems,
            builder: (context, items, _) {
              _ensureValidSelection(items);

              return Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () => _openSelector(items),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selected?.name ?? "Select an item"),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ...widget.children,
        ],
      ),
    );
  }
}

class ButtonsGroup extends StatelessWidget {
  final IconData iconData;
  final String title;
  final List<Widget> children;

  const ButtonsGroup({
    super.key,
    required this.iconData,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ExpansionTile(
            shape: const Border(),
            title: CardTitle(iconData: iconData, title: title),
            children: [
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                shrinkWrap: true,
                childAspectRatio: 2.5,
                children: children,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SdkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SdkButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class SdkCheckbox extends StatelessWidget {
  final String labelText;
  final bool value;
  final void Function(bool?) onChanged;

  const SdkCheckbox({
    super.key,
    required this.labelText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(labelText),
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CardTitle extends StatelessWidget {
  final IconData iconData;
  final String title;

  const CardTitle({
    super.key,
    required this.iconData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          Icon(iconData, color: Colors.black45),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
