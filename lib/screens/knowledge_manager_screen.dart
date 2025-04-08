import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Knowledge Dataset Model
class KnowledgeDataset {
  final String id;
  final String name;
  final String source;
  final DateTime dateAdded;
  final String size;

  KnowledgeDataset({
    required this.id,
    required this.name,
    required this.source,
    required this.dateAdded,
    required this.size,
  });
}

// Main Screen
class KnowledgeManagerScreen extends StatefulWidget {
  const KnowledgeManagerScreen({super.key});

  @override
  State<KnowledgeManagerScreen> createState() => _KnowledgeManagerScreenState();
}

class _KnowledgeManagerScreenState extends State<KnowledgeManagerScreen> {
  final List<KnowledgeDataset> _datasets = [];
  final TextEditingController _searchController = TextEditingController();
  List<KnowledgeDataset> _filteredDatasets = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredDatasets = _datasets;
    _searchController.addListener(_filterDatasets);

    // Add some sample data
    _addSampleData();
  }

  void _addSampleData() {
    setState(() {
      _datasets.addAll([
        KnowledgeDataset(
          id: '1',
          name: 'Product Documentation',
          source: 'File Upload',
          dateAdded: DateTime.now().subtract(const Duration(days: 5)),
          size: '2.4 MB',
        ),
        KnowledgeDataset(
          id: '2',
          name: 'Technical Specifications',
          source: 'Google Drive',
          dateAdded: DateTime.now().subtract(const Duration(days: 1)),
          size: '3.7 MB',
        ),
      ]);
      _filteredDatasets = List.from(_datasets);
    });
  }

  void _filterDatasets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDatasets = List.from(_datasets);
      } else {
        _filteredDatasets =
            _datasets
                .where(
                  (dataset) =>
                      dataset.name.toLowerCase().contains(query) ||
                      dataset.source.toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  void _addDataset(KnowledgeDataset dataset) {
    setState(() {
      _datasets.add(dataset);
      _filterDatasets();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.purple[400],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Dataset "${dataset.name}" added successfully',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                // Optional: Add any action button functionality here
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'DISMISS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteDataset(String id) {
    final datasetIndex = _datasets.indexWhere((dataset) => dataset.id == id);
    if (datasetIndex >= 0) {
      final deletedDataset = _datasets[datasetIndex];
      setState(() {
        _datasets.removeAt(datasetIndex);
        _filterDatasets();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.purple[400],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          content: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Đặt các phần tử ở đầu và cuối
            children: [
              Flexible(
                child: Text(
                  'Dataset "${deletedDataset.name}" deleted',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // Xử lý text dài
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _datasets.insert(datasetIndex, deletedDataset);
                    _filterDatasets();
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'UNDO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showAddDatasetDialog(String source) {
    showDialog(
      context: context,
      builder:
          (context) => AddDatasetDialog(
            onAdd: _addDataset,
            source: source, // Pass the source to the dialog
          ),
    );
  }

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => ImportOptionsBottomSheet(
            onImportSelected: (source) {
              Navigator.pop(context);
              // Here you would handle the import based on the source
              // For now, we'll just show a dialog to add a dataset
              _showAddDatasetDialog(source);
            },
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'My Knowledge',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _filterDatasets(),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: DatasetList(
              datasets: _filteredDatasets,
              onDelete: _deleteDataset,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImportOptions,
        icon: const Icon(Icons.add),
        label: const Text('Add Dataset'),
      ),
    );
  }
}

// Dataset List Widget
class DatasetList extends StatelessWidget {
  final List<KnowledgeDataset> datasets;
  final Function(String) onDelete;

  const DatasetList({
    super.key,
    required this.datasets,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_rounded, size: 64, color: Colors.purple[400]),
            const SizedBox(height: 8),
            Text(
              'No datasets found',
              style: TextStyle(
                fontSize: 14, // Kích thước chữ
                fontWeight: FontWeight.bold, // Độ đậm vừa phải
                color: Colors.black, // Màu chữ xám nhẹ
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a dataset to get started',
              style: TextStyle(
                fontSize: 14, // Kích thước chữ
                color: Colors.grey[700], // Màu chữ xám nhẹ
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: datasets.length,
      itemBuilder: (context, index) {
        final dataset = datasets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DatasetCard(
            dataset: dataset,
            onDelete: () => onDelete(dataset.id),
          ),
        );
      },
    );
  }
}

// Dataset Card Widget
class DatasetCard extends StatelessWidget {
  final KnowledgeDataset dataset;
  final VoidCallback onDelete;

  const DatasetCard({super.key, required this.dataset, required this.onDelete});

  IconData _getSourceIcon() {
    switch (dataset.source.toLowerCase()) {
      case 'file upload':
        return Icons.file_present;
      case 'website url':
        return Icons.language;
      default:
        return Icons.dataset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child:
                      dataset.source.toLowerCase() == 'google drive'
                          ? Image.asset(
                            'assets/images/ggdrive.jpg',
                            width: 24,
                            height: 24,
                          )
                          : dataset.source.toLowerCase() == 'slack'
                          ? Image.asset(
                            'assets/images/slack.png',
                            width: 24,
                            height: 24,
                          )
                          : dataset.source.toLowerCase() == 'confluence'
                          ? Image.asset(
                            'assets/images/confluence.png',
                            width: 24,
                            height: 24,
                          )
                          : Icon(_getSourceIcon(), color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dataset.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Source: ${dataset.source}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Dataset'),
                            content: Text(
                              'Are you sure you want to delete "${dataset.name}"? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete();
                                },
                                child: const Text('DELETE'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added: ${dateFormat.format(dataset.dateAdded)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  'Size: ${dataset.size}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Add Dataset Dialog Widget
class AddDatasetDialog extends StatefulWidget {
  final Function(KnowledgeDataset) onAdd;
  final String source;

  const AddDatasetDialog({
    super.key,
    required this.onAdd,
    required this.source,
  });

  @override
  State<AddDatasetDialog> createState() => _AddDatasetDialogState();
}

class _AddDatasetDialogState extends State<AddDatasetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dataset = KnowledgeDataset(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        source: widget.source,
        dateAdded: DateTime.now(),
        size: '0 KB', // This would be calculated based on actual data
      );
      widget.onAdd(dataset);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Dataset'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Dataset Name',
                hintText: 'Enter a name for this dataset',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Source: ${widget.source}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(onPressed: _submitForm, child: const Text('ADD')),
      ],
    );
  }
}

// Import Options Bottom Sheet Widget
class ImportOptionsBottomSheet extends StatelessWidget {
  final Function(String) onImportSelected;

  const ImportOptionsBottomSheet({super.key, required this.onImportSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              'Import Knowledge Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          _buildImportOption(
            context,
            'File Upload',
            Icons.file_upload,
            'Upload files from your device',
            Colors.grey,
          ),
          _buildImportOption(
            context,
            'Website URL',
            Icons.language,
            'Import data from a website',
            Colors.blue,
          ),
          _buildImportOption(
            context,
            'Google Drive',
            'assets/images/ggdrive.jpg',
            'Import from Google Drive',
            Colors.white,
          ),
          _buildImportOption(
            context,
            'Slack',
            'assets/images/slack.png',
            'Import conversations from Slack',
            Colors.white,
          ),
          _buildImportOption(
            context,
            'Confluence',
            'assets/images/confluence.png',
            'Import documents from Confluence',
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption(
    BuildContext context,
    String title,
    dynamic iconOrAsset, // Change IconData to dynamic
    String description,
    Color color,
  ) {
    return InkWell(
      onTap: () => onImportSelected(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              // Change this part to handle both IconData and String (image path)
              child:
                  iconOrAsset is IconData
                      ? Icon(iconOrAsset, color: color)
                      : Image.asset(iconOrAsset, width: 30, height: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
