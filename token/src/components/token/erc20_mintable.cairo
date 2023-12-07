/// ERC20Mintable Component
///
/// TODO: desc
#[starknet::component]
mod ERC20MintableComponent {
    use starknet::ContractAddress;
    use starknet::get_contract_address;
    use dojo::world::{
        IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait
    };

    use token::components::token::erc20_balance::ERC20BalanceComponent as erc20_balance_comp;
    use token::components::token::erc20_metadata::ERC20MetadataComponent as erc20_metadata_comp;

    use erc20_balance_comp::InternalImpl as ERC20BalanceInternal;
    use erc20_metadata_comp::InternalImpl as ERC20MetadataInternal;

    #[storage]
    struct Storage {}

    mod Errors {
        const MINT_TO_ZERO: felt252 = 'ERC20: mint to 0';
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        impl ERC20Balance: erc20_balance_comp::HasComponent<TContractState>,
        impl ERC20Metadata: erc20_metadata_comp::HasComponent<TContractState>,
        +Drop<TContractState>
    > of InternalTrait<TContractState> {
        fn _mint(
            ref self: ComponentState<TContractState>, recipient: ContractAddress, amount: u256
        ) {
            assert(!recipient.is_zero(), Errors::MINT_TO_ZERO);

            // macro is not support yet
            // let mut erc20_balance = get_dep_component_mut!(ref self, ERC20Balance);
            // let mut erc20_metadata = get_dep_component_mut!(ref self, ERC20Metadata);

            let mut contract = self.get_contract_mut();
            let mut erc20_balance = ERC20Balance::get_component_mut(ref contract);
            let mut erc20_metadata = ERC20Metadata::get_component_mut(ref contract);

            erc20_metadata._update_total_supply(0, amount);
            erc20_balance._update_balance(recipient, 0, amount);

            let transfer_event = erc20_balance_comp::Event::Transfer(
                erc20_balance_comp::Transfer {
                    from: Zeroable::zero(), to: recipient, value: amount
                }
            );

            erc20_balance.emit(transfer_event.clone());
           // emit!(self.get_contract().world(), transfer_event);
        }
    }
}
