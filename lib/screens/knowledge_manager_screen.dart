import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/knowledge.dart';
import '../services/knowledge_service.dart';

// Knowledge Dataset Model
class KnowledgeDataset {
  final String id;
  final String name;
  final String source;
  final DateTime dateAdded;

  KnowledgeDataset({
    required this.id,
    required this.name,
    required this.source,
    required this.dateAdded,
  });

  // Convert Knowledge to KnowledgeDataset
  factory KnowledgeDataset.fromKnowledge(Knowledge knowledge) {
    return KnowledgeDataset(
      id: knowledge.id,
      name: knowledge.knowledgeName,
      source: 'Knowledge Base',
      dateAdded: knowledge.createdAt,
    );
  }
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredDatasets = _datasets;
    _searchController.addListener(_filterDatasets);
    _loadKnowledges();
  }

  Future<void> _loadKnowledges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading knowledges...');
      final knowledges = await KnowledgeService.getKnowledges();
      print('Received knowledges: ${knowledges.length} items');

      setState(() {
        _datasets.clear();
        _datasets
            .addAll(knowledges.map((k) => KnowledgeDataset.fromKnowledge(k)));
        _filteredDatasets = _datasets.toList();
      });
      print('Updated datasets: ${_datasets.length} items');
    } catch (e) {
      print('Error loading knowledges: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load knowledges: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDatasets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDatasets = List.from(_datasets);
      } else {
        _filteredDatasets = _datasets
            .where(
              (dataset) =>
                  dataset.name.toLowerCase().contains(query) ||
                  dataset.source.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  Future<void> _addDataset(KnowledgeDataset dataset,
      {String? description}) async {
    if (dataset.source == 'Knowledge Base') {
      try {
        print('Creating knowledge: ${dataset.name}');
        final knowledge = await KnowledgeService.createKnowledge(
          knowledgeName: dataset.name,
          description: description ?? 'No description provided',
        );
        print('Created knowledge: ${knowledge.id}');

        setState(() {
          _datasets.add(KnowledgeDataset.fromKnowledge(knowledge));
          _filteredDatasets = _datasets.toList();
        });
        print('Updated datasets after adding: ${_datasets.length} items');

        if (mounted) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        print('Error creating knowledge: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add knowledge: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('Adding dataset from source: ${dataset.source}');
      setState(() {
        _datasets.add(dataset);
        _filteredDatasets = _datasets.toList();
      });
      print('Updated datasets after adding: ${_datasets.length} items');
    }
  }

  Future<void> _deleteDataset(KnowledgeDataset dataset) async {
    try {
      if (dataset.source == 'Knowledge Base') {
        setState(() {
          _datasets.removeWhere((d) => d.id == dataset.id);
          _filteredDatasets = _datasets.toList();
        });

        final success = await KnowledgeService.deleteKnowledge(dataset.id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('KB is deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        setState(() {
          _datasets.removeWhere((d) => d.id == dataset.id);
          _filteredDatasets = _datasets.toList();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dataset removed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        if (!_datasets.any((d) => d.id == dataset.id)) {
          _datasets.add(dataset);
          _filteredDatasets = _datasets.toList();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete dataset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddDatasetDialog(String source) {
    showDialog(
      context: context,
      builder: (context) => AddDatasetDialog(
        onAdd: _addDataset,
        source: source,
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
      builder: (context) => ImportOptionsBottomSheet(
        onImportSelected: (source) {
          Navigator.pop(context);
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
        centerTitle: true,
        title: const Text(
          'My Knowledge',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          const Icon(Icons.search,
                              color: Colors.grey, size: 16),
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
  final Function(KnowledgeDataset) onDelete;

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
            const Text(
              'No datasets found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a dataset to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
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
            onDelete: () => onDelete(dataset),
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
      case 'knowledge base':
        return Icons.article;
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
                  child: dataset.source.toLowerCase() == 'google drive'
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Source: ${dataset.source}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
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
                      builder: (context) => AlertDialog(
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
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
  final Function(KnowledgeDataset, {String? description}) onAdd;
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
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dataset = KnowledgeDataset(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        source: widget.source,
        dateAdded: DateTime.now(),
      );
      widget.onAdd(
        dataset,
        description: widget.source == 'Knowledge Base'
            ? _descriptionController.text.trim()
            : null,
      );
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
                labelText: 'Knowledge Name',
                hintText: 'Enter knowledge name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter knowledge name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.source == 'Knowledge Base') ...[
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
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
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('ADD'),
        ),
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
            'Knowledge Base',
            Icons.article,
            'Create new knowledge base',
            Colors.blue,
          ),
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
    dynamic iconOrAsset,
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
              child: iconOrAsset is IconData
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
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
