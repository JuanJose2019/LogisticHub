import Foundation

// MARK: - Localization Namespace
// Centralized string constants to avoid hardcoded string keys.

enum L10n {
    
    // MARK: - Navigation
    static let hubListTitle     = NSLocalizedString("hub_list_title", comment: "Main screen title")
    static let hubDetailTitle   = NSLocalizedString("hub_detail_title", comment: "Detail screen title")
    
    // MARK: - Search & Filter
    static let searchPrompt     = NSLocalizedString("search_prompt", comment: "Search bar placeholder")
    static let filterAll        = NSLocalizedString("filter_all", comment: "Show all hubs filter")
    
    // MARK: - Detail Labels
    static let detailInfoTitle      = NSLocalizedString("detail_info_title", comment: "")
    static let detailContactTitle   = NSLocalizedString("detail_contact_title", comment: "")
    static let detailAddress        = NSLocalizedString("detail_address", comment: "")
    static let detailCapacity       = NSLocalizedString("detail_capacity", comment: "")
    static let detailCoordinates    = NSLocalizedString("detail_coordinates", comment: "")
    static let detailCreated        = NSLocalizedString("detail_created", comment: "")
    static let detailEmail          = NSLocalizedString("detail_email", comment: "")
    static let detailPhone          = NSLocalizedString("detail_phone", comment: "")
    static let capacityUnit         = NSLocalizedString("capacity_unit", comment: "Unit label for capacity")
    
    // MARK: - Actions
    static let openInMaps   = NSLocalizedString("action_open_maps", comment: "")
    static let openInWaze   = NSLocalizedString("action_open_waze", comment: "")
    static let retry        = NSLocalizedString("action_retry", comment: "")
    static let dismiss      = NSLocalizedString("action_dismiss", comment: "")
    
    // MARK: - States
    static let loading      = NSLocalizedString("state_loading", comment: "")
    static let emptyTitle   = NSLocalizedString("state_empty_title", comment: "")
    static let emptySubtitle = NSLocalizedString("state_empty_subtitle", comment: "")
    
    // MARK: - Errors
    static let errorTitle   = NSLocalizedString("error_title", comment: "")
}
