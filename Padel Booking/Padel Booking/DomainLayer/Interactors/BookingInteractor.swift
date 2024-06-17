import Foundation
import Combine

final class BookingsInteractor: ObservableObject, AcceptBookingUseCase, RejectBookingUseCase, EditBookingUseCase, CancelBookingUseCase, CreateABookingUseCase {
    
    @Published var bookings = [
        Booking(courtId: Court.dummyCourts[0].id, startDate: Date.dateFrom(14,9,2023,17,0), endDate: Date.dateFrom(14,9,2023,18,0), title: "Event 1", isConfirmed: false),
        Booking(courtId: Court.dummyCourts[0].id, startDate: Date.dateFrom(14,9,2023,19,0), endDate: Date.dateFrom(14,9,2023,22,0), title: "Event 2", isConfirmed: false),
        Booking(courtId: Court.dummyCourts[2].id, startDate: Date.dateFrom(23,10,2023,11,0), endDate: Date.dateFrom(23,10,2023,12,00), title: "Event 3", isConfirmed: false),
        Booking(courtId: Court.dummyCourts[0].id, startDate: Date.dateFrom(23,10,2023,13,0), endDate: Date.dateFrom(23,10,2023,14,30), title: "Event 4", isConfirmed: false),
        Booking(courtId: Court.dummyCourts[1].id, startDate: Date.dateFrom(14,9,2023,15,0), endDate: Date.dateFrom(14,9,2023,16,30), title: "Event 5", isConfirmed: false)
    ]
    
    func accept(_ booking: Booking) {
        if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
            bookings[index].isConfirmed = true
        } else {
            bookings.append(booking)
        }
    }
    
    func reject(_ booking: Booking) {
        //MARK: - Implement reject booking API call here
        if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
            bookings.remove(at: index)
        }
    }
    
    func replace(id: UUID, with booking: Booking) {
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index] = booking
        }
    }
    
    func cancel(booking: Booking) {
        if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
            bookings.remove(at: index)
        }
    }
    
    func create(_ booking: Booking) -> AnyPublisher<Void, Error> {
        for _booking in bookings {
            if _booking.courtId == booking.courtId &&
                doesOverlap(_booking.startDate, _booking.endDate, booking.startDate, booking.endDate) {
                return Fail(error: BookingError.timeOverlap)
                    .eraseToAnyPublisher()
                
            }
        }
        bookings.append(booking)
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func doesOverlap(_ startDate1: Date, _ endDate1: Date, _ startDate2: Date, _ endDate2: Date) -> Bool {
        // Ensuring that end dates are greater than start dates
           guard endDate1 > startDate1, endDate2 > startDate2 else {
               // Return false or handle error as you see fit
               return false
           }
           
           // Checking for overlap
           if startDate1 >= endDate2 || startDate2 >= endDate1 {
               return false
           } else {
               return true
           }
    }
}


enum BookingError: Error {
    case timeOverlap
}
