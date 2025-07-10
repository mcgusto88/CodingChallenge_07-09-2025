import XCTest
@testable import CodingExercise7_9_2025  // Replace with your module/app target name

final class CountryListViewModelTests: XCTestCase {
    
    var viewModel: CountryListViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CountryListViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testFilterCountries_byNameOrCapital_returnsExpectedResults() {
        // Given
        viewModel.countries = [
            Country(name: "United States of America", code: "US", capital: "Washington, D.C.", region: "NA"),
            Country(name: "Uruguay", code: "UY", capital: "Montevideo", region: "SA"),
            Country(name: "India", code: "IN", capital: "New Delhi", region: "Asia")
        ]
        viewModel.isSearching = true

        let expectation = XCTestExpectation(description: "onDataChanged called")
        viewModel.onDataChanged = {
            expectation.fulfill()
        }
        
        // When
        viewModel.filter(with: "urug")  // Should match "Uruguay"

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.filteredCountries.count, 1)
        XCTAssertEqual(viewModel.filteredCountries.first?.name, "Uruguay")
    }
}
