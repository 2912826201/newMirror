class PeripheralInformationEntity {
  PeripheralInformationSuggestion suggestion;
  String count;
  String infocode;
  PeripheralInformationRegeocode regeocode;
  List<PeripheralInformationPoi> pois = [];
  String status;
  String info;

  PeripheralInformationEntity({this.suggestion, this.count, this.infocode, this.pois, this.status, this.info});

  PeripheralInformationEntity.fromJson(Map<String, dynamic> json) {
    if (json['suggestion'] != null) {
      if (json['suggestion'] is PeripheralInformationSuggestion) {
        suggestion = json['suggestion'];
      } else {
        suggestion = PeripheralInformationSuggestion.fromJson(json['suggestion']);
      }
    } else {
      suggestion = null;
    }
    count = json['count'];
    infocode = json['infocode'];
    if (json['pois'] != null) {
      pois = new List<PeripheralInformationPoi>();
      (json['pois'] as List).forEach((v) {
        if (v is PeripheralInformationPoi) {
          pois.add(v);
        } else {
          pois.add(new PeripheralInformationPoi.fromJson(v));
        }
      });
    }
    if (json['regeocode'] != null) {
      if (json['regeocode'] is PeripheralInformationRegeocode) {
        regeocode = json['regeocode'];
      } else {
        regeocode = PeripheralInformationRegeocode.fromJson(json['regeocode']);
      }
    }
    status = json['status'];
    info = json['info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.suggestion != null) {
      data['suggestion'] = this.suggestion.toJson();
    }
    data['count'] = this.count;
    data['infocode'] = this.infocode;
    if (this.pois != null) {
      data['pois'] = this.pois.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['info'] = this.info;
    return data;
  }
}

class PeripheralInformationSuggestion {
  List<Null> keywords;
  List<Null> cities;

  PeripheralInformationSuggestion({this.keywords, this.cities});

  PeripheralInformationSuggestion.fromJson(Map<String, dynamic> json) {
    if (json['keywords'] != null) {
      keywords = new List<Null>();
    }
    if (json['cities'] != null) {
      cities = new List<Null>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.keywords != null) {
      data['keywords'] = [];
    }
    if (this.cities != null) {
      data['cities'] = [];
    }
    return data;
  }
}

class PeripheralInformationPoi {
  List<Null> parent;
  dynamic address;
  List<Null> distance;
  PeripheralInformationPoisBizExt bizExt;
  String pname;
  List<Null> importance;
  List<Null> bizType;
  String cityname;
  String citycode;
  String type;
  List<PeripheralInformationPoisPhoto> photos;
  String typecode;
  String shopinfo;
  List<Null> poiweight;
  List<Null> childtype;
  String adname;
  String name;
  String location;
  String tel;
  List<Null> shopid;
  String id;

  PeripheralInformationPoi(
      {this.parent,
      this.address,
      this.distance,
      this.bizExt,
      this.pname,
      this.importance,
      this.bizType,
      this.cityname,
      this.citycode,
      this.type,
      this.photos,
      this.typecode,
      this.shopinfo,
      this.poiweight,
      this.childtype,
      this.adname,
      this.name,
      this.location,
      this.tel,
      this.shopid,
      this.id});

  PeripheralInformationPoi.fromJson(Map<String, dynamic> json) {
    if (json['parent'] != null) {
      parent = new List<Null>();
    }
    address = json['address'];
    if (json['distance'] != null) {
      distance = new List<Null>();
    }

    if (json['biz_ext'] != null) {
      if (json['biz_ext'] is PeripheralInformationPoisBizExt) {
        bizExt = json['biz_ext'];
      } else {
        bizExt = PeripheralInformationPoisBizExt.fromJson(json['biz_ext']);
      }
    } else {
      bizExt = null;
    }

    pname = json['pname'];
    cityname = json['cityname'];
    citycode = json['citycode'];
    type = json['type'];
    typecode = json['typecode'];
    shopinfo = json['shopinfo'];
    adname = json['adname'];
    name = json['name'];
    location = json['location'];

    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.parent != null) {
      data['parent'] = [];
    }
    data['address'] = this.address;
    if (this.distance != null) {
      data['distance'] = [];
    }
    if (this.bizExt != null) {
      data['biz_ext'] = this.bizExt.toJson();
    }
    data['pname'] = this.pname;
    if (this.importance != null) {
      data['importance'] = [];
    }
    if (this.bizType != null) {
      data['biz_type'] = [];
    }
    data['cityname'] = this.cityname;
    data['citycode'] = this.citycode;
    data['type'] = this.type;
    if (this.photos != null) {
      data['photos'] = this.photos.map((v) => v.toJson()).toList();
    }
    data['typecode'] = this.typecode;
    data['shopinfo'] = this.shopinfo;
    if (this.poiweight != null) {
      data['poiweight'] = [];
    }
    if (this.childtype != null) {
      data['childtype'] = [];
    }
    data['adname'] = this.adname;
    data['name'] = this.name;
    data['location'] = this.location;
    data['tel'] = this.tel;
    if (this.shopid != null) {
      data['shopid'] = [];
    }
    data['id'] = this.id;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class PeripheralInformationPoisBizExt {
  List<Null> cost;
  String rating;

  PeripheralInformationPoisBizExt({this.cost, this.rating});

  PeripheralInformationPoisBizExt.fromJson(Map<String, dynamic> json) {
    if (json['cost'] != null) {
      cost = new List<Null>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cost != null) {
      data['cost'] = [];
    }
    data['rating'] = this.rating;
    return data;
  }
}

class PeripheralInformationPoisPhoto {
  List<Null> provider;
  List<Null> title;
  String url;

  PeripheralInformationPoisPhoto({this.provider, this.title, this.url});

  PeripheralInformationPoisPhoto.fromJson(Map<String, dynamic> json) {
    if (json['provider'] != null) {
      provider = new List<Null>();
    }
    if (json['title'] != null) {
      title = new List<Null>();
    }
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.provider != null) {
      data['provider'] = [];
    }
    if (this.title != null) {
      data['title'] = [];
    }
    data['url'] = this.url;
    return data;
  }
}

class PeripheralInformationRegeocode {
  // addressComponent;
  String formatted_address;
  CityDetails cityDetails;

  PeripheralInformationRegeocode({this.formatted_address, this.cityDetails});

  PeripheralInformationRegeocode.fromJson(Map<String, dynamic> json) {
    if (json['formatted_address'] != null) {
      formatted_address = json['formatted_address'];
    }
    if (json['addressComponent'] != null) {
      cityDetails = CityDetails.fromJson(json['addressComponent']);
    }
  }
}

class CityDetails {
  // 省
  String province;

  // 市
  String city;

  // 区
  String district;

  // 街道
  String township;

  // 城市编码
  String citycode;

  CityDetails({this.city, this.province, this.district, this.township, this.citycode});

  CityDetails.fromJson(Map<String, dynamic> json) {
    if (json['province'] != null) {
      province = json['province'];
    }
    if (json['city'] != null) {
      city = json['city'].replaceAll("市", "");
    }
    if (json['district'] != null) {
      district = json['district'];
    }
    if (json['township'] != null) {
      township = json['township'];
    }
    if (json['citycode'] != null) {
      citycode = json['citycode'];
    }
  }
}
