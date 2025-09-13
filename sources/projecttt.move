module MyModule::HealthTracker {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a user's health tracking profile.
    struct HealthProfile has store, key {
        total_steps: u64,        // Total steps recorded by the user
        earned_tokens: u64,      // Total tokens earned through health activities
    }

    /// Function to create a new health profile for a user.
    public fun create_profile(user: &signer) {
        let profile = HealthProfile {
            total_steps: 0,
            earned_tokens: 0,
        };
        move_to(user, profile);
    }

    /// Function to log steps and reward tokens to the user.
    /// Rewards: 1 token per 1000 steps completed.
    public fun log_steps_and_reward(
        user: &signer, 
        steps: u64, 
        reward_provider: &signer
    ) acquires HealthProfile {
        let user_addr = signer::address_of(user);
        let profile = borrow_global_mut<HealthProfile>(user_addr);
        
        // Update user's total steps
        profile.total_steps = profile.total_steps + steps;
        
        // Calculate reward: 1 token per 1000 steps
        let reward_amount = steps / 1000;
        
        if (reward_amount > 0) {
            // Transfer reward tokens from provider to user
            let reward_coins = coin::withdraw<AptosCoin>(reward_provider, reward_amount);
            coin::deposit<AptosCoin>(user_addr, reward_coins);
            
            // Update earned tokens counter
            profile.earned_tokens = profile.earned_tokens + reward_amount;
        }
    }
}