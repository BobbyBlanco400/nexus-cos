/**
 * Notification Service
 * Handles user notifications for founding creatives
 * Part of Founding Creatives launch infrastructure
 */

class NotificationService {
  constructor(config = {}) {
    this.config = {
      channels: config.channels || ['email', 'in-app', 'push'],
      defaultChannel: config.defaultChannel || 'in-app',
      ...config
    };
    this.notifications = new Map();
    this.userPreferences = new Map();
  }

  /**
   * Initialize notification service
   */
  async initialize() {
    console.log('📬 Notification Service initializing...');
    console.log(`  📡 Channels: ${this.config.channels.join(', ')}`);
    console.log('✅ Notification Service ready');
    return true;
  }

  /**
   * Send notification to user
   * @param {string} userId - User ID
   * @param {Object} notification - Notification content
   */
  async notify(userId, notification) {
    console.log(`📬 Sending notification to user: ${userId}`);

    const notificationId = this.generateNotificationId();
    
    const record = {
      notificationId,
      userId,
      type: notification.type || 'info',
      title: notification.title,
      message: notification.message,
      channel: notification.channel || this.getUserPreferredChannel(userId),
      sentAt: Date.now(),
      status: 'sent',
      read: false
    };

    try {
      // Send through appropriate channel
      await this.sendThroughChannel(record);

      // Store notification
      this.notifications.set(notificationId, record);

      console.log(`  ✅ Notification sent via ${record.channel}`);

      return record;
    } catch (error) {
      record.status = 'failed';
      record.error = error.message;
      console.error(`❌ Notification failed: ${error.message}`);
      throw error;
    }
  }

  /**
   * Send through specific channel
   */
  async sendThroughChannel(notification) {
    switch (notification.channel) {
      case 'email':
        await this.sendEmail(notification);
        break;
      case 'in-app':
        await this.sendInApp(notification);
        break;
      case 'push':
        await this.sendPush(notification);
        break;
      default:
        console.warn(`⚠️  Unknown channel: ${notification.channel}`);
    }
  }

  /**
   * Send email notification
   */
  async sendEmail(notification) {
    console.log('    📧 Sending email...');
    // Would integrate with email service in production
    return true;
  }

  /**
   * Send in-app notification
   */
  async sendInApp(notification) {
    console.log('    📱 Sending in-app notification...');
    // Would integrate with in-app messaging system in production
    return true;
  }

  /**
   * Send push notification
   */
  async sendPush(notification) {
    console.log('    🔔 Sending push notification...');
    // Would integrate with push notification service in production
    return true;
  }

  /**
   * Send welcome message to founding creative
   */
  async sendWelcome(userId, userData) {
    return await this.notify(userId, {
      type: 'welcome',
      title: 'Welcome, Founding Creative!',
      message: `Welcome to N3XUS v-COS, ${userData.username}! Your exclusive founding creative assets are ready. You now have full stack access and founding privileges.`
    });
  }

  /**
   * Send asset ready notification
   */
  async sendAssetReady(userId, assets) {
    return await this.notify(userId, {
      type: 'asset-ready',
      title: 'Your Assets Are Ready!',
      message: `Your ${assets.length} exclusive founding creative assets have been generated and are ready for use.`
    });
  }

  /**
   * Send compliance notification
   */
  async sendComplianceUpdate(userId, complianceStatus) {
    const status = complianceStatus === 'compliant' ? 'verified' : 'requires attention';
    
    return await this.notify(userId, {
      type: 'compliance',
      title: 'Compliance Status Update',
      message: `Your compliance status has been ${status}. ${complianceStatus === 'compliant' ? 'All checks passed!' : 'Please review your compliance details.'}`
    });
  }

  /**
   * Send event invitation
   */
  async sendEventInvitation(userId, eventDetails) {
    return await this.notify(userId, {
      type: 'event',
      title: 'Live Event Invitation',
      message: `You're invited to ${eventDetails.name}! Join us on ${new Date(eventDetails.startTime).toLocaleString()} for an exclusive founding creatives session.`
    });
  }

  /**
   * Batch notify multiple users
   */
  async notifyBatch(userIds, notification) {
    console.log(`📬 Batch notifying ${userIds.length} users...`);

    const results = [];

    for (const userId of userIds) {
      try {
        const result = await this.notify(userId, notification);
        results.push({ userId, success: true, notificationId: result.notificationId });
      } catch (error) {
        results.push({ userId, success: false, error: error.message });
      }
    }

    const successful = results.filter(r => r.success).length;
    console.log(`  ✅ Batch complete: ${successful}/${userIds.length} successful`);

    return results;
  }

  /**
   * Get user preferred channel
   */
  getUserPreferredChannel(userId) {
    const prefs = this.userPreferences.get(userId);
    return prefs?.channel || this.config.defaultChannel;
  }

  /**
   * Set user preferences
   */
  setUserPreferences(userId, preferences) {
    this.userPreferences.set(userId, preferences);
    console.log(`📝 Updated preferences for user: ${userId}`);
  }

  /**
   * Mark notification as read
   */
  markAsRead(notificationId) {
    const notification = this.notifications.get(notificationId);
    
    if (notification) {
      notification.read = true;
      notification.readAt = Date.now();
      return true;
    }

    return false;
  }

  /**
   * Get user notifications
   */
  getUserNotifications(userId, options = {}) {
    const userNotifications = Array.from(this.notifications.values())
      .filter(n => n.userId === userId);

    // Apply filters
    let filtered = userNotifications;

    if (options.unreadOnly) {
      filtered = filtered.filter(n => !n.read);
    }

    if (options.type) {
      filtered = filtered.filter(n => n.type === options.type);
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.sentAt - a.sentAt);

    // Limit results
    if (options.limit) {
      filtered = filtered.slice(0, options.limit);
    }

    return filtered;
  }

  /**
   * Generate notification ID
   */
  generateNotificationId() {
    return `NOTIF_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get statistics
   */
  getStatistics() {
    const notifications = Array.from(this.notifications.values());
    const sent = notifications.filter(n => n.status === 'sent').length;
    const failed = notifications.filter(n => n.status === 'failed').length;
    const read = notifications.filter(n => n.read).length;

    const channelDistribution = {};
    notifications.forEach(n => {
      channelDistribution[n.channel] = (channelDistribution[n.channel] || 0) + 1;
    });

    return {
      totalNotifications: notifications.length,
      sent,
      failed,
      read,
      unread: sent - read,
      readRate: sent > 0 ? ((read / sent) * 100).toFixed(2) : 0,
      channelDistribution
    };
  }
}

module.exports = NotificationService;
