import ballerina/grpc;
import ballerina/protobuf;

public const string CARRENTALSYSTEM_DESC = "0A1543617252656E74616C53797374656D2E70726F746F120F43617252656E74616C53797374656D22770A045573657212160A06757365724944180120012809520675736572494412120A046E616D6518022001280952046E616D6512140A05656D61696C1803200128095205656D61696C122D0A04726F6C6518042001280E32192E43617252656E74616C53797374656D2E55736572526F6C655204726F6C6522700A08436172744974656D12140A05706C6174651801200128095205706C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E644461746512140A0570726963651804200128015205707269636522DE010A0B5265736572766174696F6E12250A0E7265736572766174696F6E5F6964180120012809520D7265736572766174696F6E4964121F0A0B637573746F6D65725F6964180220012809520A637573746F6D6572496412140A05706C6174651803200128095205706C617465121D0A0A73746172745F64617465180420012809520973746172744461746512190A08656E645F646174651805200128095207656E6444617465121F0A0B746F74616C5F7072696365180620012801520A746F74616C507269636512160A06737461747573180720012809520673746174757322D3010A0343617212140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121E0A0A6461696C795072696365180520012801520A6461696C79507269636512180A076D696C6561676518062001280552076D696C65616765123E0A0C617661696C6162696C69747918072001280E321A2E43617252656E74616C53797374656D2E436172537461747573520C617661696C6162696C69747922370A0D4164644361725265717565737412260A0363617218012001280B32142E43617252656E74616C53797374656D2E4361725203636172225A0A0E416464436172526573706F6E736512140A05706C6174651801200128095205706C61746512180A076D65737361676518022001280952076D65737361676512180A077375636365737318032001280852077375636365737322410A12437265617465557365727352657175657374122B0A05757365727318012003280B32152E43617252656E74616C53797374656D2E5573657252057573657273226D0A134372656174655573657273526573706F6E736512180A076D65737361676518012001280952076D65737361676512180A077375636365737318022001280852077375636365737312220A0C757365727343726561746564180320012805520C757365727343726561746564225E0A105570646174654361725265717565737412140A05706C6174651801200128095205706C61746512340A0A7570646174656443617218022001280B32142E43617252656E74616C53797374656D2E436172520A7570646174656443617222470A11557064617465436172526573706F6E736512180A076D65737361676518012001280952076D65737361676512180A077375636365737318022001280852077375636365737322280A1052656D6F76654361725265717565737412140A05706C6174651801200128095205706C6174652284010A1152656D6F7665436172526573706F6E7365123B0A0E72656D61696E696E675F6361727318012003280B32142E43617252656E74616C53797374656D2E436172520D72656D61696E696E674361727312180A076D65737361676518022001280952076D65737361676512180A077375636365737318032001280852077375636365737322320A184C697374417661696C61626C65436172735265717565737412160A0666696C746572180120012809520666696C74657222280A105365617263684361725265717565737412140A05706C6174651801200128095205706C61746522730A11536561726368436172526573706F6E736512260A0363617218012001280B32142E43617252656E74616C53797374656D2E4361725203636172121C0A09617661696C61626C651802200128085209617661696C61626C6512180A076D65737361676518032001280952076D6573736167652280010A10416464546F4361727452657175657374121E0A0A637573746F6D65724944180120012809520A637573746F6D6572494412140A05706C6174651802200128095205706C617465121C0A09737461727444617465180320012809520973746172744461746512180A07656E64446174651804200128095207656E644461746522470A11416464546F43617274526573706F6E736512180A076D65737361676518012001280952076D65737361676512180A077375636365737318022001280852077375636365737322390A17506C6163655265736572766174696F6E52657175657374121E0A0A637573746F6D65724944180120012809520A637573746F6D65724944228E010A18506C6163655265736572766174696F6E526573706F6E7365123E0A0B7265736572766174696F6E18012001280B321C2E43617252656E74616C53797374656D2E5265736572766174696F6E520B7265736572766174696F6E12180A076D65737361676518022001280952076D65737361676512180A07737563636573731803200128085207737563636573732A230A0855736572526F6C65120C0A08435553544F4D4552100012090A0541444D494E10012A330A0943617253746174757312130A0F4341525F554E415641494C41424C45100012110A0D4341525F415641494C41424C45100132CE050A1643617252656E74616C53797374656D5365727669636512490A06416464436172121E2E43617252656E74616C53797374656D2E416464436172526571756573741A1F2E43617252656E74616C53797374656D2E416464436172526573706F6E736512580A0B437265617465557365727312232E43617252656E74616C53797374656D2E4372656174655573657273526571756573741A242E43617252656E74616C53797374656D2E4372656174655573657273526573706F6E736512520A0955706461746543617212212E43617252656E74616C53797374656D2E557064617465436172526571756573741A222E43617252656E74616C53797374656D2E557064617465436172526573706F6E736512520A0952656D6F766543617212212E43617252656E74616C53797374656D2E52656D6F7665436172526571756573741A222E43617252656E74616C53797374656D2E52656D6F7665436172526573706F6E736512560A114C697374417661696C61626C654361727312292E43617252656E74616C53797374656D2E4C697374417661696C61626C6543617273526571756573741A142E43617252656E74616C53797374656D2E436172300112520A0953656172636843617212212E43617252656E74616C53797374656D2E536561726368436172526571756573741A222E43617252656E74616C53797374656D2E536561726368436172526573706F6E736512520A09416464546F4361727412212E43617252656E74616C53797374656D2E416464546F43617274526571756573741A222E43617252656E74616C53797374656D2E416464546F43617274526573706F6E736512670A10506C6163655265736572766174696F6E12282E43617252656E74616C53797374656D2E506C6163655265736572766174696F6E526571756573741A292E43617252656E74616C53797374656D2E506C6163655265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalSystemServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CARRENTALSYSTEM_DESC);
    }

    isolated remote function AddCar(AddCarRequest|ContextAddCarRequest req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function AddCarContext(AddCarRequest|ContextAddCarRequest req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers(CreateUsersRequest|ContextCreateUsersRequest req) returns CreateUsersResponse|grpc:Error {
        map<string|string[]> headers = {};
        CreateUsersRequest message;
        if req is ContextCreateUsersRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/CreateUsers", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CreateUsersResponse>result;
    }

    isolated remote function CreateUsersContext(CreateUsersRequest|ContextCreateUsersRequest req) returns ContextCreateUsersResponse|grpc:Error {
        map<string|string[]> headers = {};
        CreateUsersRequest message;
        if req is ContextCreateUsersRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/CreateUsers", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CreateUsersResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateCar(UpdateCarRequest|ContextUpdateCarRequest req) returns UpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdateCarResponse>result;
    }

    isolated remote function UpdateCarContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextUpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdateCarResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveCar(RemoveCarRequest|ContextRemoveCarRequest req) returns RemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemoveCarResponse>result;
    }

    isolated remote function RemoveCarContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextRemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemoveCarResponse>result, headers: respHeaders};
    }

    isolated remote function SearchCar(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function SearchCarContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function AddToCart(AddToCartRequest|ContextAddToCartRequest req) returns AddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddToCartResponse>result;
    }

    isolated remote function AddToCartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextAddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddToCartResponse>result, headers: respHeaders};
    }

    isolated remote function PlaceReservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns PlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PlaceReservationResponse>result;
    }

    isolated remote function PlaceReservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextPlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("CarRentalSystem.CarRentalSystemService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PlaceReservationResponse>result, headers: respHeaders};
    }

    isolated remote function ListAvailableCars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("CarRentalSystem.CarRentalSystemService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailableCarsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("CarRentalSystem.CarRentalSystemService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class CarRentalSystemServiceCarCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCar(Car response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCar(ContextCar response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServiceRemoveCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemoveCarResponse(RemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemoveCarResponse(ContextRemoveCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServiceCreateUsersResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersResponse(CreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersResponse(ContextCreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServiceAddToCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddToCartResponse(AddToCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddToCartResponse(ContextAddToCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServiceUpdateCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUpdateCarResponse(UpdateCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUpdateCarResponse(ContextUpdateCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServiceAddCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddCarResponse(AddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddCarResponse(ContextAddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServiceSearchCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchCarResponse(SearchCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchCarResponse(ContextSearchCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalSystemServicePlaceReservationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPlaceReservationResponse(PlaceReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPlaceReservationResponse(ContextPlaceReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationResponse record {|
    PlaceReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartResponse record {|
    AddToCartResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarResponse record {|
    UpdateCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersRequest record {|
    CreateUsersRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarRequest record {|
    AddCarRequest content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarResponse record {|
    RemoveCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarResponse record {|
    SearchCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type User record {|
    string userID = "";
    string name = "";
    string email = "";
    UserRole role = CUSTOMER;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type PlaceReservationResponse record {|
    Reservation reservation = {};
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type RemoveCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type UpdateCarRequest record {|
    string plate = "";
    Car updatedCar = {};
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type AddCarResponse record {|
    string plate = "";
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type AddToCartResponse record {|
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type UpdateCarResponse record {|
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type CartItem record {|
    string plate = "";
    string start_date = "";
    string end_date = "";
    float price = 0.0;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type AddToCartRequest record {|
    string customerID = "";
    string plate = "";
    string startDate = "";
    string endDate = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type CreateUsersRequest record {|
    User[] users = [];
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type ListAvailableCarsRequest record {|
    string filter = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type SearchCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type AddCarRequest record {|
    Car car = {};
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type RemoveCarResponse record {|
    Car[] remaining_cars = [];
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type Reservation record {|
    string reservation_id = "";
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
    float total_price = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type Car record {|
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float dailyPrice = 0.0;
    int mileage = 0;
    CarStatus availability = CAR_UNAVAILABLE;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type PlaceReservationRequest record {|
    string customerID = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type SearchCarResponse record {|
    Car car = {};
    boolean available = false;
    string message = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type CreateUsersResponse record {|
    string message = "";
    boolean success = false;
    int usersCreated = 0;
|};

public enum UserRole {
    CUSTOMER, ADMIN
}

public enum CarStatus {
    CAR_UNAVAILABLE, CAR_AVAILABLE
}

