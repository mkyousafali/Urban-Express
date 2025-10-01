<script>
  import { onMount } from 'svelte';
  import Button from '$lib/components/Button.svelte';
  import Input from '$lib/components/Input.svelte';
  import Card from '$lib/components/Card.svelte';
  
  let currentLanguage = 'ar';

  // Load language from localStorage
  onMount(() => {
    const savedLanguage = localStorage.getItem('language');
    if (savedLanguage) {
      currentLanguage = savedLanguage;
    }
  });

  // Listen for language changes
  function handleStorageChange(event) {
    if (event.key === 'language') {
      currentLanguage = event.newValue || 'ar';
    }
  }

  onMount(() => {
    window.addEventListener('storage', handleStorageChange);
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  });
  let messageText = '';
  let messages = [
    {
      id: 1,
      type: 'system',
      textAr: 'مرحباً! كيف يمكنني مساعدتك اليوم؟',
      textEn: 'Hello! How can I help you today?',
      time: '2024-10-01T10:00:00',
      sender: 'support'
    },
    {
      id: 2,
      type: 'user',
      textAr: 'أريد تتبع طلبي #2856',
      textEn: 'I want to track my order #2856',
      time: '2024-10-01T10:01:00',
      sender: 'user'
    },
    {
      id: 3,
      type: 'ai',
      textAr: 'طلبك #2856 في طريقه إليك الآن. الوصول المتوقع خلال 15 دقيقة. هل تحتاج لأي مساعدة أخرى؟',
      textEn: 'Your order #2856 is on its way to you now. Expected arrival in 15 minutes. Do you need any other assistance?',
      time: '2024-10-01T10:01:30',
      sender: 'ai'
    }
  ];
  
  let chatContainer;
  let isTyping = false;

  $: texts = currentLanguage === 'ar' ? {
    title: 'دردشة الدعم',
    typePlaceholder: 'اكتب رسالتك...',
    send: 'إرسال',
    supportAgent: 'موظف الدعم',
    aiAssistant: 'المساعد الذكي',
    you: 'أنت',
    typing: 'يكتب...',
    quickReplies: 'ردود سريعة',
    trackOrder: 'تتبع الطلب',
    reportIssue: 'الإبلاغ عن مشكلة',
    askQuestion: 'طرح سؤال'
  } : {
    title: 'Support Chat',
    typePlaceholder: 'Type your message...',
    send: 'Send',
    supportAgent: 'Support Agent',
    aiAssistant: 'AI Assistant',
    you: 'You',
    typing: 'typing...',
    quickReplies: 'Quick Replies',
    trackOrder: 'Track Order',
    reportIssue: 'Report Issue',
    askQuestion: 'Ask Question'
  };

  onMount(() => {
    scrollToBottom();
  });

  function scrollToBottom() {
    if (chatContainer) {
      chatContainer.scrollTop = chatContainer.scrollHeight;
    }
  }

  function formatTime(timeString) {
    const time = new Date(timeString);
    return time.toLocaleTimeString(currentLanguage === 'ar' ? 'ar-SA' : 'en-US', {
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  function sendMessage() {
    if (!messageText.trim()) return;

    const newMessage = {
      id: messages.length + 1,
      type: 'user',
      textAr: messageText,
      textEn: messageText,
      time: new Date().toISOString(),
      sender: 'user'
    };

    messages = [...messages, newMessage];
    messageText = '';
    
    // Simulate AI response
    simulateAIResponse();
    scrollToBottom();
  }

  function simulateAIResponse() {
    isTyping = true;
    
    setTimeout(() => {
      const aiMessage = {
        id: messages.length + 1,
        type: 'ai',
        textAr: 'شكراً لك على رسالتك. سأساعدك في حل هذه المشكلة.',
        textEn: 'Thank you for your message. I will help you resolve this issue.',
        time: new Date().toISOString(),
        sender: 'ai'
      };
      
      messages = [...messages, aiMessage];
      isTyping = false;
      scrollToBottom();
    }, 2000);
  }

  function sendQuickReply(reply) {
    messageText = currentLanguage === 'ar' ? reply.textAr : reply.textEn;
    sendMessage();
  }

  const quickReplies = [
    {
      textAr: 'تتبع طلبي',
      textEn: 'Track my order'
    },
    {
      textAr: 'الإبلاغ عن مشكلة',
      textEn: 'Report an issue'
    },
    {
      textAr: 'تغيير العنوان',
      textEn: 'Change address'
    }
  ];

  function handleKeyPress(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      sendMessage();
    }
  }
</script>

<div class="chat-container">
  <header class="chat-header">
    <h1>{texts.title}</h1>
    <div class="status-indicator online"></div>
  </header>

  <div class="chat-messages" bind:this={chatContainer}>
    {#each messages as message}
      <div class="message-wrapper" class:user={message.sender === 'user'}>
        <div class="message" class:user-message={message.sender === 'user'}>
          <div class="message-content">
            <p>{currentLanguage === 'ar' ? message.textAr : message.textEn}</p>
          </div>
          <div class="message-meta">
            <span class="sender">
              {#if message.sender === 'user'}
                {texts.you}
              {:else if message.sender === 'ai'}
                {texts.aiAssistant}
              {:else}
                {texts.supportAgent}
              {/if}
            </span>
            <span class="time">{formatTime(message.time)}</span>
          </div>
        </div>
      </div>
    {/each}

    {#if isTyping}
      <div class="message-wrapper">
        <div class="message">
          <div class="message-content">
            <div class="typing-indicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
          <div class="message-meta">
            <span class="sender">{texts.aiAssistant}</span>
            <span class="time">{texts.typing}</span>
          </div>
        </div>
      </div>
    {/if}
  </div>

  <!-- Quick Replies -->
  <div class="quick-replies">
    <h3>{texts.quickReplies}</h3>
    <div class="quick-replies-grid">
      {#each quickReplies as reply}
        <Button 
          size="sm" 
          variant="secondary" 
          on:click={() => sendQuickReply(reply)}
        >
          {currentLanguage === 'ar' ? reply.textAr : reply.textEn}
        </Button>
      {/each}
    </div>
  </div>

  <!-- Message Input -->
  <div class="message-input">
    <div class="input-group">
      <Input
        bind:value={messageText}
        placeholder={texts.typePlaceholder}
        on:keypress={handleKeyPress}
      />
      <Button on:click={sendMessage} disabled={!messageText.trim()}>
        {texts.send}
      </Button>
    </div>
  </div>
</div>

<style>
  .chat-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    background: var(--color-surface);
  }

  .chat-header {
    padding: var(--space-4);
    background: white;
    border-bottom: 1px solid var(--color-border-light);
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .chat-header h1 {
    margin: 0;
    color: var(--color-ink);
    font-size: 1.2rem;
  }

  .status-indicator {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: var(--color-success);
  }

  .chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: var(--space-4);
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  .message-wrapper {
    display: flex;
    justify-content: flex-start;
  }

  .message-wrapper.user {
    justify-content: flex-end;
  }

  .message {
    max-width: 70%;
    background: white;
    border-radius: 18px;
    padding: var(--space-3);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  .user-message {
    background: var(--gradient-primary);
    color: white;
  }

  .message-content p {
    margin: 0;
    line-height: 1.4;
  }

  .message-meta {
    display: flex;
    justify-content: space-between;
    margin-top: var(--space-2);
    font-size: 0.75rem;
    opacity: 0.7;
  }

  .typing-indicator {
    display: flex;
    gap: 4px;
    align-items: center;
  }

  .typing-indicator span {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--color-ink-light);
    animation: typing 1.4s infinite ease-in-out;
  }

  .typing-indicator span:nth-child(2) {
    animation-delay: 0.2s;
  }

  .typing-indicator span:nth-child(3) {
    animation-delay: 0.4s;
  }

  @keyframes typing {
    0%, 60%, 100% {
      transform: translateY(0);
    }
    30% {
      transform: translateY(-10px);
    }
  }

  .quick-replies {
    padding: var(--space-4);
    background: white;
    border-top: 1px solid var(--color-border-light);
  }

  .quick-replies h3 {
    margin: 0 0 var(--space-3) 0;
    font-size: 0.9rem;
    color: var(--color-ink-light);
  }

  .quick-replies-grid {
    display: flex;
    gap: var(--space-2);
    flex-wrap: wrap;
  }

  .message-input {
    padding: var(--space-4);
    background: white;
    border-top: 1px solid var(--color-border-light);
  }

  .input-group {
    display: flex;
    gap: var(--space-2);
    align-items: stretch;
  }

  .input-group :global(input) {
    flex: 1;
  }

  /* Responsive design */
  @media (max-width: 768px) {
    .message {
      max-width: 85%;
    }
  }
</style>