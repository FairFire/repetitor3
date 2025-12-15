import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repetitor/database/db_helper.dart';
import 'package:repetitor/models/comment.dart';

class StudentCommentsScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const StudentCommentsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentCommentsScreen> createState() => _StudentCommentsScreenState();
}

class _StudentCommentsScreenState extends State<StudentCommentsScreen> {
  late Future<List<Comment>> _commentsFuture;
  final TextEditingController _textController = TextEditingController();
  final dbHelper = DBHelper();
  final DateFormat _timeFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    _refreshComments();
    super.initState();
  }

  void _refreshComments() {
    setState(() {
      _commentsFuture = dbHelper.getCommentsByStudent(widget.studentId);
    });
  }

  void _addComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final comment = Comment(
      studentId: widget.studentId,
      text: text,
      createdAt: DateTime.now(),
    );
    await dbHelper.insertComment(comment);
    _textController.clear();
    _refreshComments();
  }

  void _deleteComment(int commentId) async {
    await dbHelper.deleteComment(commentId);
    _refreshComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Комментарии: ${widget.studentName}'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Нет комментариев'));
                  }
                  final comments = snapshot.data ?? [];
                  return comments.isEmpty
                      ? const Center(child: Text('Нет комментариев'))
                      : ListView.builder(
                          itemCount: comments.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _buildCommentItem(comment);
                          },
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Напишите комментарий...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'send_comment',
                    onPressed: _addComment,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(comment.text),
        subtitle: Text(_timeFormat.format(comment.createdAt)),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm =
                await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Удалить комментарий?'),
                    content: const Text('Это действие нельзя отменить.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                ) ??
                false;
            if (confirm) {
              _deleteComment(comment.id!);
            }
          },
        ),
      ),
    );
  }
}
