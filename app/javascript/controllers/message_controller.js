// app/javascript/controllers/message_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message"
export default class extends Controller {
  static values = { userId: Number }

  connect() {
    // Set message styling based on sender
    const currentUserId = parseInt(document.body.dataset.currentUserId, 10);
    if (this.userIdValue === currentUserId) {
      this.element.classList.add('sent');
      this.element.classList.remove('received');
    } else {
      this.element.classList.add('received');
      this.element.classList.remove('sent');
    }

    // Find the messages container (parent with id="messages")
    const messagesContainer = document.getElementById('messages');

    // Only scroll if this is the latest message (last child of the container)
    const isLatestMessage = this.isLatestMessage(messagesContainer);

    if (messagesContainer && isLatestMessage) {
      // Scroll the messages container to the bottom
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }

  isLatestMessage(container) {
    if (!container || !container.children.length) return false;

    // Check if this message is the last one in the container
    const lastMessage = container.children[container.children.length - 1];
    return this.element === lastMessage;
  }
}
