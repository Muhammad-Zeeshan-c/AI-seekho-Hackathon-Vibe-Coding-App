import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/ai_orchestrator.dart';
import '../../data/models/agent_trace_model.dart';

/// Premium AI chat interface — Gemini-style with agent reasoning stream
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _aiOrchestrator = AiOrchestrator();
  bool _isThinking = false;
  bool _showReasoningPanel = false;
  List<AgentStepTrace> _reasoningSteps = [];

  // Chat messages: {role: 'user'|'ai', text: String, isCard: bool}
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text': 'Assalam-o-Alaikum! 👋 Main KaamKaar AI hun.\n\nMujhe bataein aapko kya chahiye — Urdu, Roman Urdu, ya English mein. Bilkul natural bolain!\n\n_"Mujhe G-13 mein AC technician chahiye"_',
      'isCard': false,
    },
  ];

  // Suggested quick prompts
  static const _quickPrompts = [
    'Electrician chahiye ⚡',
    'AC gas fill karwana hai ❄️',
    'Pipe leaking hai 🔧',
    'Tutor dhundh raha hoon 📚',
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _msgController.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'isCard': false});
      _isThinking = true;
      _showReasoningPanel = true;
      _reasoningSteps = [];
    });
    _scrollToBottom();

    // Stream agent reasoning steps
    await for (final step in _aiOrchestrator.processRequest(text)) {
      if (!mounted) return;
      setState(() => _reasoningSteps.add(step));
      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;

    // Final AI response
    setState(() {
      _isThinking = false;
      _messages.add({
        'role': 'ai',
        'text': _buildAiResponse(text),
        'isCard': false,
      });
      // Inject provider results card
      _messages.add({'role': 'ai', 'text': '', 'isCard': true});
    });
    _scrollToBottom();
  }

  String _buildAiResponse(String input) {
    return 'Mein ne samajh liya! 🤖\n\n'
        'Aapke liye G-13 aur qareeb ke ilaqon mein available best workers dhundh liye hain. '
        'Sabse upar AI-recommended option sabse fast aur highest rated hai.\n\n'
        'Koi bhi worker select karke **Request Now** dabayein — worker 60 seconds mein accept kar lega!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppTheme.textPrimary(context)),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KaamKaar AI', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('Online', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push('/logs'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.aiPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.psychology_rounded, size: 18, color: AppTheme.aiPurple),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Agent reasoning panel
          if (_showReasoningPanel && _reasoningSteps.isNotEmpty)
            _buildReasoningPanel(context, isDark),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, i) {
                // Typing indicator
                if (_isThinking && i == _messages.length) {
                  return _buildTypingIndicator(context, isDark);
                }
                final msg = _messages[i];
                if (msg['isCard'] == true) return _buildProviderMiniCards(context, isDark);
                return _buildChatBubble(context, isDark, msg);
              },
            ),
          ),

          // Quick prompts (shown only when chat is empty/first)
          if (_messages.length <= 1)
            _buildQuickPrompts(context, isDark),

          // Input bar
          _buildInputBar(context, isDark),
        ],
      ),
    );
  }

  Widget _buildReasoningPanel(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D20) : const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.aiPurple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, size: 14, color: AppTheme.aiPurple),
              const SizedBox(width: 6),
              Text(
                'Agent Reasoning',
                style: TextStyle(color: AppTheme.aiPurple, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5),
              ),
              const Spacer(),
              if (_isThinking)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.aiPurple),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ..._reasoningSteps.map((step) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${step.agentName}: ${step.action}',
                        style: AppTheme.monoStyle(fontSize: 11, color: isDark ? AppTheme.textSecondaryDark : const Color(0xFF4C1D95)),
                      ),
                    ),
                    Text(
                      '${step.durationMs}ms',
                      style: AppTheme.monoStyle(fontSize: 10, color: AppTheme.aiPurple),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
              )),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, bool isDark, Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.primaryGradient : null,
                color: isUser ? null : AppTheme.surface(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: AppTheme.divider(context), width: 0.5),
              ),
              child: Text(
                msg['text'],
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textPrimary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18)),
              border: Border.all(color: AppTheme.divider(context), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: AppTheme.textSecondary(context), shape: BoxShape.circle),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(delay: (i * 200).ms, duration: 400.ms)
                    .fadeOut(delay: (i * 200 + 400).ms, duration: 400.ms);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderMiniCards(BuildContext context, bool isDark) {
    final providers = MockProviderDatabase_placeholder.placeholders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 38, bottom: 8),
          child: Text('Top matches found 👇', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 38),
            itemCount: providers.length,
            itemBuilder: (context, i) {
              final p = providers[i];
              return GestureDetector(
                onTap: () => context.push('/provider/${p['id']}'),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: i == 0 ? AppTheme.primary.withOpacity(0.4) : AppTheme.divider(context),
                      width: i == 0 ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(6)),
                          child: const Text('🤖 Top Pick', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      Text(p['name']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary(context))),
                      Text(p['category']!, style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(p['rating']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context))),
                          const Spacer(),
                          Text('~${p['eta']}', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (100 * i).ms).fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: GestureDetector(
            onTap: () => context.push('/results?category=All'),
            child: Text(
              'See all providers →',
              style: TextStyle(color: isDark ? AppTheme.primaryDark : AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildQuickPrompts(BuildContext context, bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _quickPrompts.map((prompt) {
          return GestureDetector(
            onTap: () => _sendMessage(prompt),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider(context), width: 0.5),
              ),
              child: Text(prompt, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(top: BorderSide(color: AppTheme.divider(context), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface2Dark : const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.divider(context), width: 0.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Bolo kya chahiye...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        hintStyle: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14),
                      ),
                      style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 14),
                      onSubmitted: _sendMessage,
                      maxLines: 1,
                    ),
                  ),
                  // Mic button
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.mic_rounded, color: AppTheme.textSecondary(context), size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: () => _sendMessage(_msgController.text),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal placeholder for chat card providers (avoiding full mock import in chat)
class MockProviderDatabase_placeholder {
  static const placeholders = [
    {'id': 'PRV-001', 'name': 'Ali Hassan', 'category': 'Electrician', 'rating': '4.9', 'eta': '12 min'},
    {'id': 'PRV-002', 'name': 'Ahmed Raza', 'category': 'Electrician', 'rating': '4.7', 'eta': '18 min'},
    {'id': 'PRV-003', 'name': 'Usman Khan', 'category': 'Electrician', 'rating': '4.6', 'eta': '22 min'},
  ];
}
